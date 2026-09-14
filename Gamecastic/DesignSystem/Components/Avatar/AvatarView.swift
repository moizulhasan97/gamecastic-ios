//
//  AvatarView.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 31/08/2026.
//

import SwiftUI

/// The signed-in hunter's picture, wherever it appears — top bar, side menu,
/// profile header.
///
/// One component rather than three call sites drawing their own circle, because
/// the fallback chain is the fiddly part and it should behave identically
/// everywhere: picture → initials → generic glyph. The picture can be missing for
/// perfectly ordinary reasons (no `picture` claim in the ID token, a user who
/// never uploaded one), so initials are the expected state, not an error state.
struct AvatarView: View {
    @Environment(\.theme) private var theme
    
    let url: URL?
    var name: String? = nil
    var email: String? = nil
    var size: CGFloat = 34
    /// Ring colour. `nil` draws no ring.
    var ringColor: Color? = nil
    var ringWidth: CGFloat = 1.5
    
    var body: some View {
        placeholder
            .frame(width: size, height: size)
            .overlay {
                if let url {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            // Keep the initials visible while loading and after a
                            // failure — a blank circle reads as a broken avatar.
                            Color.clear
                        }
                    }
                }
            }
            .clipShape(Circle())
            .overlay {
                if let ringColor {
                    Circle().stroke(ringColor, lineWidth: ringWidth)
                }
            }
            .accessibilityHidden(true)
    }
    
    @ViewBuilder private var placeholder: some View {
        if let initials {
            Circle()
                .fill(theme.currentTheme.g100)
                .overlay {
                    Text(verbatim: initials)
                        .font(.custom(FontProvider.inter(weight: .bold).fontName, size: size * 0.38))
                        .foregroundColor(theme.currentTheme.g700)
                }
        } else {
            Image(systemName: "person.crop.circle")
                .resizable()
                .scaledToFit()
                .foregroundColor(theme.currentTheme.g500)
        }
    }
    
    /// Up to two initials from the display name, falling back to the email's first
    /// character. Nil when we know nothing about the user — a signed-out top bar.
    private var initials: String? {
        if let name, !name.trimmingCharacters(in: .whitespaces).isEmpty {
            let letters = name
                .split(separator: " ")
                .prefix(2)
                .compactMap { $0.first }
                .map(String.init)
            if !letters.isEmpty { return letters.joined().uppercased() }
        }
        if let first = email?.first {
            return String(first).uppercased()
        }
        return nil
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 16) {
        AvatarView(url: nil, name: "Moiz Ul Hasan", size: 44, ringColor: .green)
        AvatarView(url: nil, email: "hunter@gamecastic.com", size: 44)
        AvatarView(url: nil, size: 44)
    }
    .padding()
}
