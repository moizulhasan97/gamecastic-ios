//
//  BorderColors.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import SwiftUI

enum BorderColors {
    case primary
    case primaryMid
    case onDark
    
    func color(using theme: AppThemeManager) -> Color {
        switch self {
        case .primary: return theme.currentTheme.border
        case .primaryMid: return theme.currentTheme.borderMid
        case .onDark: return theme.currentTheme.snow
        }
    }
}
