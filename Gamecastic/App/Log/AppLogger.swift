//
//  AppLogger.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import Foundation
import os.log

fileprivate enum LogLevel: Int, Comparable {
    case debug = 0, info, warning, error
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool { lhs.rawValue < rhs.rawValue }
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
}

enum AppEnvironment {
    static var isDebug: Bool {
#if DEBUG
        true
#else
        false
#endif
    }
}

enum AppLogger {
    private static var minimumLogLevel: LogLevel { AppEnvironment.isDebug ? .debug : .error }
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Gamecastic", category: "App")
    
    static func warning(_ message: @autoclosure () -> String, file: String = #fileID, line: Int = #line) {
        log(.warning, message(), file: file, line: line)
    }
    
    static func localizationFallbackToDefault(key: String, table: String?, defaultUsed: String, file: String = #fileID, line: Int = #line) {
        warning("[Localization] Missing key '\(key)' (table: \(table ?? "Localizable")); using default: \"\(defaultUsed)\"", file: file, line: line)
    }
    
    static func fontsUnavailable(names: [String], registered: [String], file: String = #fileID, line: Int = #line) {
        warning(
            "[Fonts] Not registered: \(names.joined(separator: ", ")). "
            + "Font.custom() will silently fall back to the system font. "
            + "PostScript names actually available: \(registered.joined(separator: ", "))",
            file: file, line: line
        )
    }
    
    private static func log(_ level: LogLevel, _ message: String, file: String, line: Int) {
        guard level >= minimumLogLevel else { return }
        logger.log(level: level.osLogType, "[\(file):\(line)] \(message)")
    }
}
