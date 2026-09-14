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
        case .filter:
            return FilterCategoryChipStyle(theme: theme)
        }
    }
}

// MARK: - Concrete style

struct DefaultCategoryChipStyle: CategoryChipStyleProtocol {
    enum ChipType {
        /// The category rail on Home: outlined, orange text when selected.
        case standard
        /// The quick-filter row on search results: solid orange fill when selected.
        case filter
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

/// The quick-filter pill on the search surfaces.
///
/// It differs from `.standard` in emphasis, not in shape: a selected filter is a
/// solid orange pill because several can be on at once and they need to read as a
/// set at a glance, whereas the category rail marks a single current section.
struct FilterCategoryChipStyle: CategoryChipStyleProtocol {
    let theme: AppThemeManager
    
    var backgroundColor: Color { theme.currentTheme.snow }
    var backgroundSelectedColor: Color { theme.currentTheme.orange }
    var backgroundHighlightedColor: Color { theme.currentTheme.paper }
    var backgroundDisabledColor: Color { theme.currentTheme.paper }
    
    var titleColor: Color { theme.currentTheme.ink }
    var titleSelectedColor: Color { theme.currentTheme.snow }
    var titleDisabledColor: Color { theme.currentTheme.g300 }
    
    var borderColor: Color { theme.currentTheme.border }
    /// Selected chips are filled, so the border would only muddy the edge.
    var borderSelectedColor: Color { .clear }
    var borderDisabledColor: Color { theme.currentTheme.g200 }
    var borderWidth: CGFloat { 1 }
    
    var font: Font { theme.typography.titleMedium.font }
    var cornerRadius: CornerRadius { .capsule }
}
