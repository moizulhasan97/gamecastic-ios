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
    /// `TextTypography` — if a style's size or weight changes, every call site
    /// picks it up automatically instead of being hunted down one `.font()` at a time.
    ///
    ///     Text(title).typography { $0.button1 } // title: Localized
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
        content.font(style(theme.typography).font)
    }
}

// MARK: - Preview

#Preview {
    // `Localized("...")` (not a bare string literal) — see the note in TopBarView.swift
    // about why a raw literal passed to `Text(...)` is ambiguous in this codebase.
    Text(Localized("Request to Book"))
        .typography { $0.button1 }
        .padding()
}
