//
//  HTTPMethod.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

/// Supported HTTP verbs. Kept intentionally small; extend as endpoints need it.
nonisolated enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
