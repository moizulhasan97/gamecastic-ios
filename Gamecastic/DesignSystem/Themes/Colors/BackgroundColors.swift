//
//  BackgroundColors.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import SwiftUI

enum BackgroundColors {
    case action        // primary CTA fill
    case surface        // card / sheet background
    case appBackground   // screen background
    
    func color(using theme: AppThemeManager) -> Color {
        switch self {
        case .action: return theme.currentTheme.orange
        case .surface: return theme.currentTheme.snow
        case .appBackground: return theme.currentTheme.paper
        }
    }
}
