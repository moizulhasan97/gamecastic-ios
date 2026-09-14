//
//  AppTheme+Environment.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppThemeManager = .shared
}

extension EnvironmentValues {
    var theme: AppThemeManager {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}
