//
//  WebAuthenticator.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import AuthenticationServices
import UIKit

/// Wraps `ASWebAuthenticationSession` — Apple's secure, sandboxed browser for
/// OAuth. It presents the identity server's hosted login page (so email/password,
/// 2FA, "forgot password" and account creation all happen there, not in native
/// UI) and hands back the redirect URL containing the authorization code.
@MainActor
final class WebAuthenticator: NSObject {
    
    /// Presents the login page and resolves with the callback URL, or throws
    /// `AuthError.cancelled` if the user dismisses it.
    func start(url: URL, callbackScheme: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callback: .customScheme(callbackScheme)
            ) { callbackURL, error in
                if let error {
                    if let asError = error as? ASWebAuthenticationSessionError,
                       asError.code == .canceledLogin {
                        continuation.resume(throwing: AuthError.cancelled)
                    } else {
                        continuation.resume(throwing: AuthError.transport(error.localizedDescription))
                    }
                    return
                }
                guard let callbackURL else {
                    continuation.resume(throwing: AuthError.unknown("No callback URL returned."))
                    return
                }
                continuation.resume(returning: callbackURL)
            }
            session.presentationContextProvider = self
            // Persistent (not ephemeral) so the hosted "remember this device"
            // option and SSO can work across launches.
            session.prefersEphemeralWebBrowserSession = false
            if !session.start() {
                continuation.resume(throwing: AuthError.unknown("Could not start the authentication session."))
            }
        }
    }
}

extension WebAuthenticator: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // The active foreground window to anchor the auth sheet to.
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        return scene?.keyWindow ?? ASPresentationAnchor()
    }
}
