//
//  TokenResponseDTO.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// Raw success payload from `POST /connect/token`. This is standard OAuth JSON,
/// NOT the app's `{success,message,data,error}` envelope — which is exactly why
/// auth calls don't go through the shared `APIClient`.
nonisolated struct TokenResponseDTO: Decodable, Sendable {
    let accessToken: String
    let tokenType: String?
    let expiresIn: Int?
    let refreshToken: String?
    let idToken: String?
    let scope: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken  = "access_token"
        case tokenType    = "token_type"
        case expiresIn    = "expires_in"
        case refreshToken = "refresh_token"
        case idToken      = "id_token"
        case scope
    }
}

/// Raw error payload from the token endpoint (RFC 6749 §5.2), e.g.
/// `{ "error": "invalid_grant", "error_description": "..." }`.
nonisolated struct OAuthErrorDTO: Decodable, Sendable {
    let error: String
    let errorDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}
