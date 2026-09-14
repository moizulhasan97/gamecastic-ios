//
//  OIDCConfig.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// Everything the OAuth 2.0 / OpenID Connect Authorization Code + PKCE flow needs.
///
/// The web portal authenticates against the Gamecastic Identity Server
/// (`identity-dev.gamecastic.com`) using this exact flow; the iOS app mirrors it
/// via `ASWebAuthenticationSession`.
///
/// ⚠️ Several values below are BACKEND-DEPENDENT — see the TODOs. Nothing here can
/// succeed until the backend team registers a *mobile* client for us.
nonisolated struct OIDCConfig: Sendable {
    
    let issuer: URL
    let authorizationEndpoint: URL
    let tokenEndpoint: URL
    let endSessionEndpoint: URL
    let userInfoEndpoint: URL
    
    let clientID: String
    let redirectURI: String
    /// The scheme portion of `redirectURI` that `ASWebAuthenticationSession` watches for.
    let callbackScheme: String
    let scopes: [String]
    
    /// Master switch for the whole feature. Flip to `true` ONLY once the backend
    /// has registered the mobile client + redirect URI (TODOs below). While
    /// `false`, `AuthManager.signIn()` short-circuits with a toast instead of
    /// launching a flow that would just error out.
    let isMobileClientConfigured: Bool
    
    var scopeString: String { scopes.joined(separator: " ") }
    
    /// Development configuration.
    static let development = OIDCConfig(
        issuer:                URL(string: "https://identity-dev.gamecastic.com/")!,
        authorizationEndpoint: URL(string: "https://identity-dev.gamecastic.com/connect/authorize")!,
        tokenEndpoint:         URL(string: "https://identity-dev.gamecastic.com/connect/token")!,
        endSessionEndpoint:    URL(string: "https://identity-dev.gamecastic.com/connect/logout")!,
        userInfoEndpoint:      URL(string: "https://identity-dev.gamecastic.com/connect/userinfo")!,
        
        // TODO(backend #1): STILL NEED the real client id from backend.
        clientID: "gamecastic-mobile",
        
        // CONFIRMED by backend 2026-08-19. Note the single slash ":/callback" is
        // intentional (Duende-style path callback) — must match byte-for-byte.
        redirectURI: "com.gamecastic.app:/callback",
        callbackScheme: "com.gamecastic.app",   // scheme only — ASWebAuthenticationSession matches on this
        
        // CONFIRMED: backend issues both access + refresh tokens.
        scopes: ["openid", "profile", "email", "api", "offline_access"],
        
        // TODO(backend #4): flip to true once client id (#1) is confirmed & the client is live.
        isMobileClientConfigured: true
    )
    
    /// The active configuration. Swap by environment alongside `AppConfig`.
    static let current: OIDCConfig = .development
}
