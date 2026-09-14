//
//  TextTypography.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

/// Central switches for how type behaves app-wide.
enum TypographyConfig {
    
    /// When `true`, every token scales with the user's Dynamic Type setting.
    ///
    /// Left `false` until the fixed-height surfaces (chips, cards, the top bar) have
    /// been audited at the accessibility sizes — turning it on is a one-line change
    /// here rather than a sweep through the views, which is the whole point of routing
    /// type through tokens. Pin a specific subtree with `.dynamicTypeSize(...)` if it
    /// genuinely cannot flex.
    static let scalesWithDynamicType = false
}

/// One text style: a face, a size, and the typographic details that travel with them.
///
/// `tracking` and `textCase` live here rather than at the call site because they are
/// properties of the *style*, not of the content — an eyebrow label is uppercase and
/// tracked wherever it appears.
protocol Typography {
    /// Point size at the default Dynamic Type setting.
    var size: CGFloat { get }
    /// Which face renders this style.
    var face: FontProvider { get }
    /// System text style this scales against when Dynamic Type is enabled.
    var textStyle: Font.TextStyle { get }
    /// Letter spacing in points. `0` means the face's natural spacing.
    var tracking: CGFloat { get }
    /// Casing enforced by the style, if any.
    var textCase: Text.Case? { get }
    /// The resolved SwiftUI font.
    var font: Font { get }
}

extension Typography {
    var textStyle: Font.TextStyle { .body }
    var tracking: CGFloat { 0 }
    var textCase: Text.Case? { nil }
    
    var font: Font {
        face.font(
            size: size,
            relativeTo: TypographyConfig.scalesWithDynamicType ? textStyle : nil
        )
    }
}

/// The app's type ramp.
///
/// Seven roles, each with a face that never changes — so picking a token picks the
/// right face automatically and no view has to know a PostScript name:
///
/// - **Display** — DM Serif Display. Editorial moments only: hero titles, section
///   headers. Single weight; never bolded.
/// - **Heading** — Inter Bold. Screen and card titles that are structural rather than
///   editorial (a person's name, a price).
/// - **Title** — Inter SemiBold. Row and card titles, emphasised inline text.
/// - **Body** — Inter Regular. Running copy and descriptions.
/// - **Label** — Inter Medium. Interactive and functional text: fields, chips, rows.
/// - **Stat** — Inter Bold. Prices and ratings: short, emphatic, read as a value
///   rather than as prose. Distinct from Heading because a price is not a title.
/// - **Overline** — Inter Bold/ExtraBold, uppercase and tracked. Badges, eyebrows, meta.
/// - **Button** — Inter ExtraBold. Casing and tracking come from the button style,
///   not the token, so `AppButton` stays in charge of its own treatment.
protocol TextTypography {
    
    // Display — DM Serif Display
    var displayLarge: Typography { get }    // 28
    var displayMedium: Typography { get }   // 22
    var displaySmall: Typography { get }    // 19
    var displayXSmall: Typography { get }   // 16
    
    // Heading — Inter Bold
    var headingLarge: Typography { get }    // 24
    var headingMedium: Typography { get }   // 20
    var headingSmall: Typography { get }    // 16
    
    // Title — Inter SemiBold
    var titleLarge: Typography { get }      // 17
    var titleMedium: Typography { get }     // 15
    var titleSmall: Typography { get }      // 13
    
    // Body — Inter Regular
    var bodyLarge: Typography { get }       // 15
    var bodyMedium: Typography { get }      // 14
    var bodySmall: Typography { get }       // 12
    
    // Label — Inter Medium
    var labelLarge: Typography { get }      // 15
    var labelMedium: Typography { get }     // 14
    var labelSmall: Typography { get }      // 12
    var labelXSmall: Typography { get }     // 10
    
    // Stat — Inter Bold, for numbers that carry weight (price, rating)
    var statLarge: Typography { get }       // 16
    var statSmall: Typography { get }       // 13
    
    // Overline — uppercase, tracked
    var overlineLarge: Typography { get }   // 11
    var overlineMedium: Typography { get }  // 10
    var overlineSmall: Typography { get }   // 9
    
    // Button
    var button1: Typography { get }         // 14
}
