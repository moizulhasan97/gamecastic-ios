//
//  TextColors.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import SwiftUI

enum TextColors {
    case body
    case action
    case onAction
    case tertiary
    case onDark
    
    func color(using theme: AppThemeManager) -> Color {
        switch self {
        case .body: return theme.currentTheme.ink
        case .action: return theme.currentTheme.orange
        case .onAction: return theme.currentTheme.snow
        case .tertiary: return theme.currentTheme.leather
        case .onDark: return theme.currentTheme.paper
        }
    }
}
