//
//  AppThemeManager.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import Combine

final class AppThemeManager: ObservableObject {
    static let shared = AppThemeManager()
    
    @Published private(set) var currentTheme: any AppTheme
    @Published private(set) var viewConfig: any ViewConfig
    @Published private(set) var buttonStyle: (any ButtonStyleProvider)!
    @Published private(set) var categoryChipStyle: (any CategoryChipStyleProvider)!
    @Published private(set) var typography: any TextTypography
    
    private init() {
        self.currentTheme = DefaultTheme()
        self.viewConfig = DefaultViewConfig()
        self.typography = DefaultTextTypography()
        self.buttonStyle = DefaultThemeButtonStyleProvider(theme: self)
        self.categoryChipStyle = DefaultThemeCategoryChipStyleProvider(theme: self)
    }
}
