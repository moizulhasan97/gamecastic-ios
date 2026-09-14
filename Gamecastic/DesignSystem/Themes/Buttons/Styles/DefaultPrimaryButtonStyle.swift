//
//  DefaultPrimaryButtonStyle.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import SwiftUI

struct DefaultPrimaryButtonStyle: ButtonStyleProtocol {
    let theme: AppThemeManager
    
    var backgroundColor: Color { theme.currentTheme.orange }
    var backgroundHighlightedColor: Color { theme.currentTheme.orangeDeep }
    var backgroundDisabledColor: Color { theme.currentTheme.orange.opacity(0.4) }
    
    var titleColor: Color { theme.currentTheme.snow }
    var titleHighlightedColor: Color { theme.currentTheme.snow }
    var titleDisabledColor: Color { theme.currentTheme.snow.opacity(0.7) }
    
    var borderWidth: CGFloat { 0 }
    var borderColor: Color { .clear }
    var borderHighlightedColor: Color { .clear }
    var borderDisabledColor: Color { .clear }
    
    var font: Font { theme.typography.button1.font }
    var cornerRadius: CornerRadius { theme.viewConfig.buttonCornerRadius }
}
