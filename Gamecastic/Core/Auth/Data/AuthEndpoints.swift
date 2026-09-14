//
//  AuthEndpoints.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// Builds the concrete requests for the Authorization Code + PKCE flow.
/// Pure request construction — no networking — so it's trivially testable.
nonisolated enum AuthEndpoints {
    
    /// The hosted-login URL we hand to `ASWebAuthenticationSession`.
    static func authorizeURL(config: OIDCConfig, pkce: PKCE, state: String) -> URL {
        var components = URLComponents(url: config.authorizationEndpoint, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "response_type", value: "code"),
            .init(name: "client_id", value: config.clientID),
            .init(name: "redirect_uri", value: config.redirectURI),
            .init(name: "scope", value: config.scopeString),
            .init(name: "code_challenge", value: pkce.challenge),
            .init(name: "code_challenge_method", value: pkce.method),
            .init(name: "state", value: state)
        ]
        return components.url!
    }
    
    /// Exchanges an authorization `code` for tokens.
    static func tokenExchangeRequest(config: OIDCConfig, code: String, codeVerifier: String) -> URLRequest {
        formPOST(to: config.tokenEndpoint, fields: [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": config.redirectURI,
            "client_id": config.clientID,
            "code_verifier": codeVerifier
        ])
    }
    
    /// Renews tokens using a refresh token.
    static func refreshRequest(config: OIDCConfig, refreshToken: String) -> URLRequest {
        formPOST(to: config.tokenEndpoint, fields: [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": config.clientID
        ])
    }
    
    // MARK: - Helpers
    
    private static func formPOST(to url: URL, fields: [String: String]) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = fields
            .map { "\(formEncode($0.key))=\(formEncode($0.value))" }
            .joined(separator: "&")
            .data(using: .utf8)
        return request
    }
    
    private static func formEncode(_ value: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }
}
