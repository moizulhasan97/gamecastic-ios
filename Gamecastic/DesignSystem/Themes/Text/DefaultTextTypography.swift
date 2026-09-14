//
//  DefaultTextTypography.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import SwiftUI

/// A concrete text style. One generic value type instead of a struct per token —
/// tokens differ only in their data, so a struct each would be twenty near-identical
/// declarations to maintain.
struct TextStyleToken: Typography {
    let face: FontProvider
    let size: CGFloat
    let textStyle: Font.TextStyle
    let tracking: CGFloat
    let textCase: Text.Case?
    
    init(
        _ face: FontProvider,
        _ size: CGFloat,
        _ textStyle: Font.TextStyle,
        tracking: CGFloat = 0,
        textCase: Text.Case? = nil
    ) {
        self.face = face
        self.size = size
        self.textStyle = textStyle
        self.tracking = tracking
        self.textCase = textCase
    }
}

/// The default ramp. Sizes are the ones already in use across Home, HuntSearch and
/// Account, consolidated onto a scale — a few call sites shift by a point when they
/// migrate, which is the intended trade for having a scale at all.
struct DefaultTextTypography: TextTypography {
    
    // MARK: Display — DM Serif Display (single weight, never bolded)
    
    var displayLarge: Typography  { TextStyleToken(.dmSerifDisplay, 28, .largeTitle) }
    var displayMedium: Typography { TextStyleToken(.dmSerifDisplay, 22, .title) }
    var displaySmall: Typography  { TextStyleToken(.dmSerifDisplay, 19, .title2) }
    var displayXSmall: Typography { TextStyleToken(.dmSerifDisplay, 16, .title3) }
    
    // MARK: Heading — Inter Bold
    
    var headingLarge: Typography  { TextStyleToken(.inter(weight: .bold), 24, .title) }
    var headingMedium: Typography { TextStyleToken(.inter(weight: .bold), 20, .title2) }
    var headingSmall: Typography  { TextStyleToken(.inter(weight: .bold), 16, .headline) }
    
    // MARK: Title — Inter SemiBold
    
    var titleLarge: Typography    { TextStyleToken(.inter(weight: .semiBold), 17, .headline) }
    var titleMedium: Typography   { TextStyleToken(.inter(weight: .semiBold), 15, .subheadline) }
    var titleSmall: Typography    { TextStyleToken(.inter(weight: .semiBold), 13, .footnote) }
    
    // MARK: Body — Inter Regular
    
    var bodyLarge: Typography     { TextStyleToken(.inter(weight: .regular), 15, .body) }
    var bodyMedium: Typography    { TextStyleToken(.inter(weight: .regular), 14, .callout) }
    var bodySmall: Typography     { TextStyleToken(.inter(weight: .regular), 12, .caption) }
    
    // MARK: Label — Inter Medium
    
    var labelLarge: Typography    { TextStyleToken(.inter(weight: .medium), 15, .subheadline) }
    var labelMedium: Typography   { TextStyleToken(.inter(weight: .medium), 14, .callout) }
    var labelSmall: Typography    { TextStyleToken(.inter(weight: .medium), 12, .caption) }
    var labelXSmall: Typography   { TextStyleToken(.inter(weight: .medium), 10, .caption2) }
    
    // MARK: Stat — Inter Bold
    
    var statLarge: Typography     { TextStyleToken(.inter(weight: .bold), 16, .headline) }
    var statSmall: Typography     { TextStyleToken(.inter(weight: .bold), 13, .footnote) }
    
    // MARK: Overline — uppercase, tracked
    
    var overlineLarge: Typography {
        TextStyleToken(.inter(weight: .bold), 11, .caption, tracking: 0.6, textCase: .uppercase)
    }
    /// ExtraBold, not SemiBold: at 10pt this is a filled badge ("FAMILY FRIENDLY",
    /// "SOON") and needs the extra weight to hold its own against the fill.
    var overlineMedium: Typography {
        TextStyleToken(.inter(weight: .extraBold), 10, .caption2, tracking: 0.5, textCase: .uppercase)
    }
    var overlineSmall: Typography {
        TextStyleToken(.inter(weight: .bold), 9, .caption2, tracking: 0.4, textCase: .uppercase)
    }
    
    // MARK: Button
    
    /// Casing and tracking stay `nil`/`0` on purpose: `AppButton` applies them from
    /// its `ButtonStyleProvider`, so putting them here too would fight that.
    var button1: Typography { TextStyleToken(.inter(weight: .extraBold), 14, .headline) }
}
