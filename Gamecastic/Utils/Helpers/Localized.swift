//
//  Localized.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import Foundation

private enum LocalizedLookupConstants {
    static let missingKeySentinel = "\u{FFFC}LOCALIZATION_KEY_MISSING\u{FFFC}"
}

struct Localized: ExpressibleByStringLiteral {
    let key: String
    let defaultValue: String
    let table: String?
    let comment: String
    
    init(stringLiteral value: StringLiteralType) {
        self.key = value
        self.defaultValue = value
        self.table = nil
        self.comment = ""
    }
    
    init(_ key: String, default defaultValue: String, table: String? = nil, comment: String = "") {
        self.key = key
        self.defaultValue = defaultValue
        self.table = table
        self.comment = comment
    }
    
    init(_ key: String, table: String? = nil, comment: String = "") {
        self.key = key
        self.defaultValue = key
        self.table = table
        self.comment = comment
    }
    
    func resolve(_ args: CVarArg...) -> String {
        let lookedUp = NSLocalizedString(
            key, tableName: table, bundle: .main,
            value: LocalizedLookupConstants.missingKeySentinel, comment: comment
        )
        let base: String
        if lookedUp == LocalizedLookupConstants.missingKeySentinel {
            AppLogger.localizationFallbackToDefault(key: key, table: table, defaultUsed: defaultValue)
            base = defaultValue
        } else {
            base = lookedUp
        }
        return args.isEmpty ? base : String(format: base, arguments: args)
    }
    
    func callAsFunction(_ args: CVarArg...) -> String {
        resolve(args)
    }
}
