//
//  FontProvider.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// The app's font faces — and the single place PostScript names are allowed to live.
///
/// ⚠️ `Font.custom(_:size:)` resolves a font by its **PostScript name**, not by the
/// filename. Get the name wrong and SwiftUI silently substitutes the system font:
/// no crash, no warning, the app just quietly stops being Inter.
///
/// The bundled Inter files are Google's optical-size build, whose PostScript names
/// are `Inter18pt-*` — *not* `Inter-*`, despite what the `.ttf` filenames say. Every
/// name therefore lives in this enum and nowhere else, so a mismatch can only ever
/// be made once. Run `FontProvider.auditBundledFonts()` in a DEBUG build to verify.
enum FontProvider {
    
    /// Inter's weight axis. DM Serif Display has no weight axis — see `dmSerifDisplay`.
    enum Weight {
        case light      // 300
        case regular    // 400
        case medium     // 500
        case semiBold   // 600
        case bold       // 700
        case extraBold  // 800
    }
    
    /// Inter — the UI face: body copy, labels, buttons, numbers.
    case inter(weight: Weight)
    
    /// DM Serif Display — the editorial display face the web design uses for card and
    /// section titles.
    ///
    /// It ships in a single weight upstream (Regular is the whole family, plus an
    /// italic), so it deliberately takes no `Weight`. Never apply `.bold()` or
    /// `.fontWeight()` to it: with no bold cut available the system synthesises one by
    /// smearing the glyphs, which looks wrong at display sizes.
    case dmSerifDisplay
    
    /// The PostScript name, as registered through `UIAppFonts` in Info.plist.
    var fontName: String {
        switch self {
        case .inter(let weight):
            switch weight {
            case .light:     return "Inter18pt-Light"
            case .regular:   return "Inter18pt-Regular"
            case .medium:    return "Inter18pt-Medium"
            case .semiBold:  return "Inter18pt-SemiBold"
            case .bold:      return "Inter18pt-Bold"
            case .extraBold: return "Inter18pt-ExtraBold"
            }
        case .dmSerifDisplay:
            return "DMSerifDisplay-Regular"
        }
    }
    
    /// A `Font` for this face at `size`.
    ///
    /// - Parameter textStyle: when non-nil the font scales with Dynamic Type, anchored
    ///   to that system text style. Whether tokens pass one is decided centrally by
    ///   `TypographyConfig.scalesWithDynamicType`, so the whole app flips together
    ///   rather than view by view.
    func font(size: CGFloat, relativeTo textStyle: Font.TextStyle? = nil) -> Font {
        if let textStyle {
            return .custom(fontName, size: size, relativeTo: textStyle)
        }
        return .custom(fontName, size: size)
    }
    
    /// Legacy call shape, kept so existing call sites keep compiling while they are
    /// migrated. Prefer `.typography { $0.bodyLarge }` — see `TextTypography`.
    static func getFont(name: String, size: CGFloat) -> Font {
        Font.custom(name, size: size)
    }
}

// MARK: - Debug audit

#if DEBUG
extension FontProvider {
    
    /// Every face the app expects to find in the bundle.
    private static var allFaces: [FontProvider] {
        [
            .inter(weight: .light),
            .inter(weight: .regular),
            .inter(weight: .medium),
            .inter(weight: .semiBold),
            .inter(weight: .bold),
            .inter(weight: .extraBold),
            .dmSerifDisplay
        ]
    }
    
    /// Logs any face that fails to resolve, together with the PostScript names iOS
    /// actually registered — the fastest way to spot a filename/PostScript-name
    /// mismatch, which otherwise fails silently.
    ///
    /// Call once from `GamecasticApp.init()`. DEBUG-only; compiled out of release.
    static func auditBundledFonts() {
#if canImport(UIKit)
        let missing = allFaces
            .map(\.fontName)
            .filter { UIFont(name: $0, size: 12) == nil }
        
        guard !missing.isEmpty else { return }
        
        let registered = UIFont.familyNames
            .sorted()
            .flatMap { UIFont.fontNames(forFamilyName: $0) }
            .filter { !$0.hasPrefix(".") && !$0.hasPrefix("System") }
        
        AppLogger.fontsUnavailable(names: missing, registered: registered)
#endif
    }
}
#endif
