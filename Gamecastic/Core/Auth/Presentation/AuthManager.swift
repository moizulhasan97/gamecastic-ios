//
//  AuthManager.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Combine
import Foundation

/// App-wide source of truth for authentication.
///
/// - Publishes `AuthState` for the UI (sign-in buttons, gated actions).
/// - Provides a fresh access token to the networking layer via
///   `validAccessToken()`, refreshing transparently when needed.
///
/// Singleton to match the app's other app-wide managers (`AppThemeManager`,
/// `ToastManager`) and so the networking layer can read the token without
/// threading the instance through every view-model factory.
@MainActor
final class AuthManager: ObservableObject {
    
    static let shared = AuthManager()
    
    @Published private(set) var state: AuthState = .unknown
    
    private let config: OIDCConfig
    private let tokenClient: AuthTokenClient
    private let store: any TokenStore
    
    private var tokens: AuthTokens?
    /// Coalesces concurrent refreshes into one in-flight request.
    private var refreshTask: Task<AuthTokens, Error>?
    
    /// Built lazily so `init` can stay `nonisolated`. `WebAuthenticator` is
    /// `@MainActor` and is only ever used from `signIn()` (already on the main
    /// actor), so its first construction happens safely on the main actor.
    private lazy var webAuth = WebAuthenticator()
    
    /// `nonisolated` so `static let shared = AuthManager()` can construct it from
    /// the (nonisolated) static-property initializer without hopping to the main
    /// actor. It only stores nonisolated/`Sendable` dependencies, so no
    /// main-actor state is touched during initialization.
    nonisolated private init(
        config: OIDCConfig = .current,
        tokenClient: AuthTokenClient = AuthTokenClient(),
        store: any TokenStore = KeychainTokenStore()
    ) {
        self.config = config
        self.tokenClient = tokenClient
        self.store = store
    }
    
    var isAuthenticated: Bool {
        if case .authenticated = state { return true }
        return false
    }
    
    /// The signed-in hunter, or nil in every other state. Saves callers from
    /// pattern-matching `state` just to read a name or an avatar.
    var currentUser: AuthenticatedUser? {
        if case let .authenticated(user) = state { return user }
        return nil
    }
    
    // MARK: - Launch restore
    
    /// Call once on app launch. Restores a stored session (refreshing if the
    /// access token has expired) and moves `state` off `.unknown`.
    func restoreSession() async {
        guard let stored = store.load() else {
            state = .unauthenticated
            return
        }
        let restored = AuthTokens(
            accessToken: stored.accessToken,
            refreshToken: stored.refreshToken,
            idToken: stored.idToken,
            accessTokenExpiry: stored.accessTokenExpiry
        )
        tokens = restored
        let user = AuthenticatedUser(
            subject: stored.subject,
            email: stored.email,
            name: stored.name,
            pictureURL: stored.pictureURL.flatMap(URL.init(string:))
        )
        
        if restored.isAccessTokenValid() {
            state = .authenticated(user)
        } else if restored.refreshToken != nil {
            do {
                _ = try await refreshTokens()
                state = .authenticated(user)
            } catch {
                AppLogger.warning("[Auth] Restore refresh failed: \(error)")
                clearSession()
            }
        } else {
            clearSession()
        }
    }
    
    // MARK: - Sign in
    
    /// Starts the hosted Authorization Code + PKCE flow.
    func signIn() async {
        // Until the backend registers our mobile client + redirect URI, there's
        // nothing to talk to — fail loudly but gracefully instead of launching a
        // flow that would just error. Remove this guard once
        // `OIDCConfig.isMobileClientConfigured` is flipped to true.
        guard config.isMobileClientConfigured else {
            let message = "Sign-in isn't wired up yet: the iOS OAuth client and redirect scheme still need to be registered with the backend."
            print("⚠️ [Auth] \(message) See OIDCConfig TODOs #1–#4.")
            AppLogger.warning("[Auth] signIn blocked — mobile client not configured.")
            ToastManager.shared.show(message)
            return
        }
        
        let pkce = PKCE()
        let sentState = OAuthRandom.makeState()
        
        do {
            let authorizeURL = AuthEndpoints.authorizeURL(config: config, pkce: pkce, state: sentState)
            let callbackURL = try await webAuth.start(url: authorizeURL, callbackScheme: config.callbackScheme)
            
            let (code, returnedState) = try parseCallback(callbackURL)
            guard returnedState == sentState else { throw AuthError.stateMismatch }
            
            let dto = try await tokenClient.exchange(code: code, codeVerifier: pkce.verifier, config: config)
            try applyTokenResponse(dto)
        } catch AuthError.cancelled {
            AppLogger.warning("[Auth] Sign-in cancelled by user.")   // no error toast for a deliberate dismiss
        } catch {
            handle(error, context: "sign in")
        }
    }
    
    // MARK: - Sign out
    
    func signOut() {
        // TODO(backend #5): Optionally hit the end-session endpoint in a browser to
        // clear the identity server's OWN session cookie:
        //   config.endSessionEndpoint (+ id_token_hint & post_logout_redirect_uri).
        // For v1 we clear locally, which signs THIS app out.
        clearSession()
    }
    
    // MARK: - Token access for the networking layer
    
    /// Returns a currently-valid access token, refreshing if needed. `nil` when
    /// signed out or when refresh fails. Wired into `DefaultAPIClient`'s
    /// `tokenProvider`.
    func validAccessToken() async -> String? {
        guard isAuthenticated, let current = tokens else { return nil }
        if current.isAccessTokenValid() { return current.accessToken }
        guard current.refreshToken != nil else { clearSession(); return nil }
        do {
            let refreshed = try await refreshTokens()
            return refreshed.accessToken
        } catch {
            AppLogger.warning("[Auth] Token refresh failed, signing out: \(error)")
            clearSession()
            return nil
        }
    }
    
    // MARK: - Private
    
    private func refreshTokens() async throws -> AuthTokens {
        if let refreshTask { return try await refreshTask.value }
        guard let refreshToken = tokens?.refreshToken else { throw AuthError.noRefreshToken }
        
        let task = Task { () throws -> AuthTokens in
            let dto = try await tokenClient.refresh(refreshToken: refreshToken, config: config)
            return try makeTokens(from: dto, fallbackRefreshToken: refreshToken)
        }
        refreshTask = task
        defer { refreshTask = nil }
        
        let newTokens = try await task.value
        tokens = newTokens
        persist(newTokens)
        return newTokens
    }
    
    private func applyTokenResponse(_ dto: TokenResponseDTO) throws {
        let newTokens = try makeTokens(from: dto, fallbackRefreshToken: nil)
        tokens = newTokens
        let user = IDTokenDecoder.user(from: newTokens.idToken)
        ?? AuthenticatedUser(subject: "unknown", email: nil, name: nil)
        persist(newTokens, user: user)
        state = .authenticated(user)
    }
    
    private func makeTokens(from dto: TokenResponseDTO, fallbackRefreshToken: String?) throws -> AuthTokens {
        let expiry = Date().addingTimeInterval(TimeInterval(dto.expiresIn ?? 3600))
        return AuthTokens(
            accessToken: dto.accessToken,
            // OpenIddict rotates refresh tokens: keep the new one, else reuse the old.
            refreshToken: dto.refreshToken ?? fallbackRefreshToken,
            idToken: dto.idToken,
            accessTokenExpiry: expiry
        )
    }
    
    private func persist(_ newTokens: AuthTokens, user: AuthenticatedUser? = nil) {
        let existingUser: AuthenticatedUser?
        if case let .authenticated(u) = state { existingUser = u } else { existingUser = nil }
        let resolved = user ?? existingUser
        let stored = StoredSession(
            accessToken: newTokens.accessToken,
            refreshToken: newTokens.refreshToken,
            idToken: newTokens.idToken,
            accessTokenExpiry: newTokens.accessTokenExpiry,
            subject: resolved?.subject ?? "unknown",
            email: resolved?.email,
            name: resolved?.name,
            pictureURL: resolved?.pictureURL?.absoluteString
        )
        do { try store.save(stored) } catch { AppLogger.warning("[Auth] Keychain persist failed: \(error)") }
    }
    
    private func clearSession() {
        tokens = nil
        refreshTask?.cancel()
        refreshTask = nil
        store.clear()
        state = .unauthenticated
    }
    
    private func parseCallback(_ url: URL) throws -> (code: String, state: String?) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw AuthError.missingAuthorizationCode
        }
        let items = components.queryItems ?? []
        if let error = items.first(where: { $0.name == "error" })?.value {
            let description = items.first(where: { $0.name == "error_description" })?.value
            throw AuthError.oauth(code: error, description: description)
        }
        guard let code = items.first(where: { $0.name == "code" })?.value else {
            throw AuthError.missingAuthorizationCode
        }
        let returnedState = items.first(where: { $0.name == "state" })?.value
        return (code, returnedState)
    }
    
    private func handle(_ error: Error, context: String) {
        AppLogger.warning("[Auth] Failed to \(context): \(error)")
        let message: String
        switch error {
        case AuthError.stateMismatch:
            message = "We couldn't verify the sign-in response. Please try again."
        case let AuthError.oauth(code, description):
            message = "Sign-in failed (\(code)). \(description ?? "Please try again.")"
        default:
            message = "Something went wrong signing in. Please try again."
        }
        ToastManager.shared.show(message)
    }
}

/// Minimal, UNVERIFIED decode of the ID token payload for display only.
/// We trust these claims solely because the token came straight from the token
/// endpoint over TLS — the signature is NOT validated here. Never make a security
/// decision from these values without server-side verification.
nonisolated enum IDTokenDecoder {
    static func user(from idToken: String?) -> AuthenticatedUser? {
        guard let idToken else { return nil }
        let segments = idToken.split(separator: ".")
        guard segments.count >= 2 else { return nil }
        var base64 = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        let subject = (json["sub"] as? String) ?? "unknown"
        let email = json["email"] as? String
        let name = (json["name"] as? String) ?? (json["preferred_username"] as? String)
        let picture = (json["picture"] as? String).flatMap(URL.init(string:))
        return AuthenticatedUser(subject: subject, email: email, name: name, pictureURL: picture)
    }
}
