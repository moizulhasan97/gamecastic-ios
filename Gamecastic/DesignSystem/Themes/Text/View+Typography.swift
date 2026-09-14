//
//  View+Typography.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

extension View {
    /// Applies a themed text style resolved from the current `AppThemeManager`.
    ///
    /// Use this instead of `.font(...)` so type styles stay centrally defined in
    /// `TextTypography` — if a style's size, face or weight changes, every call site
    /// picks it up automatically instead of being hunted down one `.font()` at a time.
    /// It also means no view has to know a PostScript name, which is exactly the class
    /// of bug that made every `.custom("Inter-…")` call silently render in the system
    /// font (see `FontProvider`).
    ///
    ///     Text(title).typography { $0.titleMedium } // title: Localized
    ///
    /// The style's `tracking` and `textCase` ride along with the font, since both are
    /// properties of the style rather than of the content.
    ///
    /// - Parameter style: Selects the `Typography` to apply from the current theme's
    ///   `TextTypography`. A closure (rather than a fixed case) so this scales as more
    ///   text styles are added to `TextTypography` without needing API changes here.
    func typography(_ style: @escaping (any TextTypography) -> Typography) -> some View {
        modifier(TypographyModifier(style: style))
    }
}

private struct TypographyModifier: ViewModifier {
    @Environment(\.theme) private var theme

    let style: (any TextTypography) -> Typography

    func body(content: Content) -> some View {
        let token = style(theme.typography)
        
        // Only applied when the token asks for them: an unconditional `.tracking(0)`
        // or `.textCase(nil)` would override whatever an ancestor had set.
        content
            .font(token.font)
            .modifier(TrackingModifier(tracking: token.tracking))
            .modifier(TextCaseModifier(textCase: token.textCase))
    }
}

private struct TrackingModifier: ViewModifier {
    let tracking: CGFloat
    
    @ViewBuilder func body(content: Content) -> some View {
        if tracking == 0 {
            content
        } else {
            content.tracking(tracking)
        }
    }
}

private struct TextCaseModifier: ViewModifier {
    let textCase: Text.Case?
    
    @ViewBuilder func body(content: Content) -> some View {
        if let textCase {
            content.textCase(textCase)
        } else {
            content
        }
    }
}

// MARK: - Preview

#Preview {
    // `Localized("...")` (not a bare string literal) — see the note in TopBarView.swift
    // about why a raw literal passed to `Text(...)` is ambiguous in this codebase.
    VStack(alignment: .leading, spacing: 14) {
        Text(Localized("Hill Country Trophy Whitetail")).typography { $0.displayMedium }
        Text(Localized("Lone Star Backcountry")).typography { $0.headingSmall }
        Text(Localized("Fredericksburg, TX · Morning")).typography { $0.bodyMedium }
        Text(Localized("Family Friendly")).typography { $0.overlineLarge }
        Text(Localized("Request to Book")).typography { $0.button1 }
    }
    .padding()
}
