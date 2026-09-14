//
//  Endpoint.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

/// A declarative description of a single API request.
///
/// Feature layers describe *what* they want (path, method, query, body) and the
/// `APIClient` decides *how* to send it (base URL, auth header, decoding).
nonisolated struct Endpoint: Sendable {
    var path: String                       // e.g. "home", "hunts/facets"
    var method: HTTPMethod = .get
    var queryItems: [URLQueryItem] = []
    var body: Data? = nil

    /// Builds a concrete `URLRequest` against the given base URL.
    func urlRequest(baseURL: URL, authToken: String?) throws -> URLRequest {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        guard let url = components?.url else {
            throw APIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if let authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
