//
//  AppConfig.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

/// Central place for environment-specific configuration.
///
/// As staging / production come online, add cases to `Environment` and switch
/// `current` via a build setting or xcconfig — no call site needs to change.
nonisolated enum AppConfig {

    enum Environment {
        case development
        // case staging
        // case production

        /// Base URL for the REST API, including the version path segment.
        var apiBaseURL: URL {
            switch self {
            case .development:
                return URL(string: "https://api-dev.gamecastic.com/api/v1")!
            }
        }

        /// Base URL for served media / images (CDN).
        var mediaBaseURL: URL {
            switch self {
            case .development:
                return URL(string: "https://media-dev.gamecastic.com")!
            }
        }
    }

    /// The environment the app currently targets.
    /// Swap this via a build configuration when more environments exist.
    static let current: Environment = .development
}
