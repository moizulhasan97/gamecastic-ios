//
//  AuthTokenClient.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// Thin `URLSession` client for the identity server's token endpoint. Kept
/// separate from `APIClient` because the identity host and its OAuth payloads
/// differ from the app API and its envelope.
nonisolated struct AuthTokenClient: Sendable {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    func exchange(code: String, codeVerifier: String, config: OIDCConfig) async throws -> TokenResponseDTO {
        try await perform(AuthEndpoints.tokenExchangeRequest(config: config, code: code, codeVerifier: codeVerifier))
    }
    
    func refresh(refreshToken: String, config: OIDCConfig) async throws -> TokenResponseDTO {
        try await perform(AuthEndpoints.refreshRequest(config: config, refreshToken: refreshToken))
    }
    
    private func perform(_ request: URLRequest) async throws -> TokenResponseDTO {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw AuthError.transport(error.localizedDescription)
        }
        guard let http = response as? HTTPURLResponse else {
            throw AuthError.unknown("Non-HTTP response from token endpoint.")
        }
        guard (200..<300).contains(http.statusCode) else {
            if let oauthError = try? decoder.decode(OAuthErrorDTO.self, from: data) {
                throw AuthError.oauth(code: oauthError.error, description: oauthError.errorDescription)
            }
            throw AuthError.oauth(code: "http_\(http.statusCode)", description: nil)
        }
        do {
            return try decoder.decode(TokenResponseDTO.self, from: data)
        } catch {
            throw AuthError.decoding(String(describing: error))
        }
    }
}
