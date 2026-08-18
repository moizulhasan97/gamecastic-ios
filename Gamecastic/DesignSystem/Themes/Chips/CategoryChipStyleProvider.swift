//
//  CategoryChipStyleProvider.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

protocol CategoryChipStyleProvider {
    func style(for type: DefaultCategoryChipStyle.ChipType) -> any CategoryChipStyleProtocol
}

struct DefaultThemeCategoryChipStyleProvider: CategoryChipStyleProvider {
    private let theme: AppThemeManager
    init(theme: AppThemeManager) { self.theme = theme }
    
    func style(for type: DefaultCategoryChipStyle.ChipType) -> any CategoryChipStyleProtocol {
        switch type {
        case .standard:
            return DefaultCategoryChipStyle(theme: theme)
        }
    }
}

// MARK: - Concrete style

struct DefaultCategoryChipStyle: CategoryChipStyleProtocol {
    enum ChipType {
        case standard
        // Add `.onDark` etc. here if a screen needs a variant later.
    }
    
    let theme: AppThemeManager
    
    var backgroundColor: Color { theme.currentTheme.snow }
    var backgroundSelectedColor: Color { theme.currentTheme.snow }
    var backgroundHighlightedColor: Color { theme.currentTheme.paper }
    var backgroundDisabledColor: Color { theme.currentTheme.paper }
    
    var titleColor: Color { theme.currentTheme.ink }
    var titleSelectedColor: Color { theme.currentTheme.orange }
    var titleDisabledColor: Color { theme.currentTheme.g300 }
    
    var borderColor: Color { theme.currentTheme.borderMid }
    var borderSelectedColor: Color { theme.currentTheme.orange }
    var borderDisabledColor: Color { theme.currentTheme.g200 }
    var borderWidth: CGFloat { 1.5 }
    
    var font: Font { theme.typography.button1.font }
    var cornerRadius: CornerRadius { .capsule }
}
