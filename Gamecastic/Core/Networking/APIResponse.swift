//
//  APIResponse.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

/// The standard server envelope shared by every Gamecastic API response.
///
/// Example:
/// ```json
/// { "success": true, "message": "Success", "data": { ... }, "error": null }
/// ```
///
/// `T` is the endpoint-specific payload found under `data`.
nonisolated struct APIResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let success: Bool
    let message: String?
    let data: T?
    let error: APIServerError?
}

/// Structured server-side error, present under `error` when `success == false`.
nonisolated struct APIServerError: Decodable, Sendable, Error {
    let code: String?
    let message: String?
}
