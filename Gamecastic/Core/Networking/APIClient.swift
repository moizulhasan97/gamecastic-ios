//
//  APIClient.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

/// Sends `Endpoint` values, unwraps the standard `APIResponse` envelope and
/// returns the decoded `data` payload.
protocol APIClient: Sendable {
    func send<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
}

final class DefaultAPIClient: APIClient {
    
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let tokenProvider: @Sendable () async -> String?   // CHANGED: now async
    
    init(
        baseURL: URL = AppConfig.current.apiBaseURL,
        session: URLSession = .shared,
        tokenProvider: @escaping @Sendable () async -> String? = { nil }   // CHANGED: now async
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenProvider = tokenProvider
        self.decoder = JSONDecoder()
    }
    
    func send<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        let token = await tokenProvider()                                  // CHANGED: await
        let request = try endpoint.urlRequest(baseURL: baseURL, authToken: token)
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error.localizedDescription)
        }
        
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.http(status: http.statusCode)
        }
        
        let envelope: APIResponse<T>
        do {
            envelope = try decoder.decode(APIResponse<T>.self, from: data)
        } catch {
            throw APIError.decoding(String(describing: error))
        }
        
        if envelope.success == false, let serverError = envelope.error {
            throw APIError.server(serverError)
        }
        guard let payload = envelope.data else {
            throw APIError.unexpectedEmptyData
        }
        return payload
    }
}
