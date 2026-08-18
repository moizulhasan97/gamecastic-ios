//
//  DefaultOverlayButtonStyle.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import SwiftUI

struct DefaultOverlayButtonStyle: ButtonStyleProtocol {
    let theme: AppThemeManager
    
    var backgroundColor: Color { theme.currentTheme.paper.opacity(0.10) }
    var backgroundHighlightedColor: Color { theme.currentTheme.paper.opacity(0.20) }
    var backgroundDisabledColor: Color { theme.currentTheme.paper.opacity(0.05) }
    
    var titleColor: Color { theme.currentTheme.paper }
    var titleHighlightedColor: Color { theme.currentTheme.paper }
    var titleDisabledColor: Color { theme.currentTheme.paper.opacity(0.4) }
    
    var borderWidth: CGFloat { 1 }
    var borderColor: Color { theme.currentTheme.paper.opacity(0.18) }
    var borderHighlightedColor: Color { theme.currentTheme.paper.opacity(0.3) }
    var borderDisabledColor: Color { theme.currentTheme.paper.opacity(0.1) }
    
    var font: Font { theme.typography.button1.font }
    var cornerRadius: CornerRadius { theme.viewConfig.buttonCornerRadius }
}
