//
//  DefaultOutlineOnDarkButtonStyle.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import SwiftUI

struct DefaultOutlineOnDarkButtonStyle: ButtonStyleProtocol {
    let theme: AppThemeManager
    
    var backgroundColor: Color { .clear }
    var backgroundHighlightedColor: Color { theme.currentTheme.snow.opacity(0.08) }
    var backgroundDisabledColor: Color { .clear }
    
    var titleColor: Color { theme.currentTheme.snow }
    var titleHighlightedColor: Color { theme.currentTheme.snow }
    var titleDisabledColor: Color { theme.currentTheme.snow.opacity(0.4) }
    
    var borderWidth: CGFloat { 1.5 }
    var borderColor: Color { theme.currentTheme.snow.opacity(0.3) }
    var borderHighlightedColor: Color { theme.currentTheme.snow.opacity(0.5) }
    var borderDisabledColor: Color { theme.currentTheme.snow.opacity(0.15) }
    
    var font: Font { theme.typography.button1.font }
    var cornerRadius: CornerRadius { theme.viewConfig.buttonCornerRadius }
}
