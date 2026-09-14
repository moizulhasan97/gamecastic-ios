//
//  PKCE.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import CryptoKit
import Foundation

/// A PKCE (Proof Key for Code Exchange) verifier/challenge pair.
///
/// PKCE is what lets a public mobile client run the Authorization Code flow
/// safely without a client secret: we keep the random `verifier` on-device, send
/// only its SHA-256 hash (`challenge`) in the authorize request, then prove
/// ownership by presenting the `verifier` when exchanging the code for tokens.
nonisolated struct PKCE: Sendable {
    let verifier: String
    let challenge: String
    let method = "S256"
    
    init() {
        let verifier = PKCE.makeCodeVerifier()
        self.verifier = verifier
        self.challenge = PKCE.makeChallenge(from: verifier)
    }
    
    /// 32 random bytes, base64url-encoded → a high-entropy verifier.
    private static func makeCodeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64URLEncodedString()
    }
    
    /// challenge = base64url( SHA256( verifier ) )
    private static func makeChallenge(from verifier: String) -> String {
        let digest = SHA256.hash(data: Data(verifier.utf8))
        return Data(digest).base64URLEncodedString()
    }
}

/// Random URL-safe value used for the OAuth `state` (CSRF) parameter.
nonisolated enum OAuthRandom {
    static func makeState() -> String {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64URLEncodedString()
    }
}

extension Data {
    /// base64url without padding, per RFC 7636.
    nonisolated func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
