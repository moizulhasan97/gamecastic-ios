//
//  KeychainTokenStore.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation
import Security

/// Persistence model for the signed-in session, stored as a single JSON blob in
/// the Keychain. Kept distinct from the domain `AuthTokens`/`AuthenticatedUser`
/// so the storage format can evolve independently.
nonisolated struct StoredSession: Codable, Sendable {
    let accessToken: String
    let refreshToken: String?
    let idToken: String?
    let accessTokenExpiry: Date
    let subject: String
    let email: String?
    let name: String?
    /// Optional so an already-stored session written before this field existed
    /// still decodes — synthesised `Decodable` treats optionals as absent-tolerant.
    let pictureURL: String?
}

/// Abstraction so `AuthManager` can be tested with an in-memory store and so the
/// backing store can be swapped later without touching callers.
protocol TokenStore: Sendable {
    func save(_ session: StoredSession) throws
    func load() -> StoredSession?
    func clear()
}

/// Keychain-backed `TokenStore`. Secure at rest, survives app restarts, wiped on
/// `clear()` (logout). No mutable state → safe to share across actors.
nonisolated final class KeychainTokenStore: TokenStore {
    
    private let service: String
    private let account = "primary-session"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(service: String = (Bundle.main.bundleIdentifier ?? "com.gamecastic.customer") + ".auth") {
        self.service = service
    }
    
    func save(_ session: StoredSession) throws {
        let data = try encoder.encode(session)
        var query = baseQuery()
        // Remove any existing item, then add fresh — the simplest correct upsert.
        SecItemDelete(query as CFDictionary)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AuthError.unknown("Keychain save failed (OSStatus \(status)).")
        }
    }
    
    func load() -> StoredSession? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return try? decoder.decode(StoredSession.self, from: data)
    }
    
    func clear() {
        SecItemDelete(baseQuery() as CFDictionary)
    }
    
    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
