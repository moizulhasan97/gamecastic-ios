//
//  ButtonStyleProvider.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


protocol ButtonStyleProvider {
    func style(for type: DefaultButtonStyle.ButtonType) -> any ButtonStyleProtocol
}

struct DefaultThemeButtonStyleProvider: ButtonStyleProvider {
    private let theme: AppThemeManager
    init(theme: AppThemeManager) { self.theme = theme }
    
    func style(for type: DefaultButtonStyle.ButtonType) -> any ButtonStyleProtocol {
        switch type {
        case .primary:
            return DefaultPrimaryButtonStyle(theme: theme)
        case .overlay:
            return DefaultOverlayButtonStyle(theme: theme)
        case .outlineOnDark:
            return DefaultOutlineOnDarkButtonStyle(theme: theme)
        }
    }
}
