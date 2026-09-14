//
//  AuthModels.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// The app-wide authentication state. `AuthManager` publishes this and the UI
/// reacts to it. `.unknown` is the launch state until we've tried to restore a
/// stored session, so the UI can avoid flashing a signed-out state.
nonisolated enum AuthState: Sendable, Equatable {
    case unknown
    case authenticated(AuthenticatedUser)
    case unauthenticated
}

/// Minimal identity of the signed-in hunter, parsed from the ID token claims.
/// Extend as we start caring about more claims.
nonisolated struct AuthenticatedUser: Sendable, Equatable {
    let subject: String            // OIDC `sub` — stable, unique user id
    let email: String?
    let name: String?
    /// OIDC `picture` claim. Often absent — `AvatarView` falls back to initials,
    /// so treat nil as ordinary rather than as a missing-data error.
    let pictureURL: URL?

    init(subject: String, email: String?, name: String?, pictureURL: URL? = nil) {
        self.subject = subject
        self.email = email
        self.name = name
        self.pictureURL = pictureURL
    }
}

/// OAuth tokens plus the moment the access token stops being valid.
/// `nonisolated` + `Sendable` so the networking layer can read them off the main actor.
nonisolated struct AuthTokens: Sendable, Equatable {
    let accessToken: String
    let refreshToken: String?
    let idToken: String?
    /// Absolute expiry of `accessToken`, computed from `expires_in` at issue time.
    let accessTokenExpiry: Date
    
    /// True while the access token is still safely usable. The leeway makes us
    /// refresh slightly early rather than mid-request.
    func isAccessTokenValid(leeway: TimeInterval = 60, now: Date = Date()) -> Bool {
        now.addingTimeInterval(leeway) < accessTokenExpiry
    }
}

/// Errors surfaced by the auth layer. Kept separate from `APIError` because the
/// identity server speaks OAuth, not the app's `{success,message,data,error}` envelope.
nonisolated enum AuthError: Error, Sendable, Equatable {
    /// The mobile OAuth client / redirect scheme isn't registered with the
    /// backend yet, so we can't even start the flow.
    case notConfigured
    /// The user closed the login sheet before finishing.
    case cancelled
    /// The `state` we sent didn't match what came back — possible tampering.
    case stateMismatch
    /// The redirect came back without an authorization code.
    case missingAuthorizationCode
    /// The identity server returned an OAuth error (e.g. `invalid_grant`).
    case oauth(code: String, description: String?)
    /// Networking / transport failure talking to the identity server.
    case transport(String)
    /// The token response couldn't be decoded.
    case decoding(String)
    /// We expected a refresh token but the session has none (can't renew).
    case noRefreshToken
    /// Any other unexpected failure.
    case unknown(String)
}
