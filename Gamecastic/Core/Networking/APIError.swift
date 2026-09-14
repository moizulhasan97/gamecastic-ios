//
//  APIError.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

/// Transport / decoding / protocol errors surfaced by the networking layer.
///
/// Server-reported business errors are represented separately by `APIServerError`
/// (carried in `.server`).
nonisolated enum APIError: Error, Sendable {
    /// The response was not an `HTTPURLResponse`.
    case invalidResponse
    /// A non-2xx status code was returned.
    case http(status: Int)
    /// The body could not be decoded into the expected type.
    case decoding(String)
    /// The server returned `success == false` with a structured error.
    case server(APIServerError)
    /// The underlying `URLSession` request failed (offline, timeout, …).
    case transport(String)
    /// A 2xx response decoded successfully but contained no `data`.
    case unexpectedEmptyData
}
