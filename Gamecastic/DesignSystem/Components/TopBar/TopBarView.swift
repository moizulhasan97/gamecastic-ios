//
//  TopBarView.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

struct TopBarView: View {
    @Environment(\.theme) private var theme

    // NOTE: These go through `Localized` (rather than raw string literals) so they stay
    // localizable, and so `Text(...)` below isn't ambiguous — a bare literal like `Text("Menu")`
    // can't tell our `Text(Localized, CVarArg...)` initializer apart from SwiftUI's own
    // `Text(LocalizedStringKey)`, which fails to compile ("ambiguous use of 'init'").
    private enum Strings {
        static let menu: Localized = "Menu"
        static let logoAccessibilityLabel: Localized = "Gamecastic"
        static let profile: Localized = "Profile"
        static let profileUnread: Localized = "Profile, unread notifications"
    }

    private let hasUnreadNotifications: Bool
    private let onMenuTap: () -> Void
    private let onProfileTap: () -> Void
    
    init(
        hasUnreadNotifications: Bool = false,
        onMenuTap: @escaping () -> Void = {},
        onProfileTap: @escaping () -> Void = {}
    ) {
        self.hasUnreadNotifications = hasUnreadNotifications
        self.onMenuTap = onMenuTap
        self.onProfileTap = onProfileTap
    }
    
    var body: some View {
        HStack(spacing: 12) {
            menuButton
            logo
            Spacer(minLength: 8)
            profileButton
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(theme.currentTheme.snow)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.currentTheme.border)
                .frame(height: 1)
        }
    }
    
    // MARK: - Menu
    
    private var menuButton: some View {
        Button(action: onMenuTap) {
            // TODO: Replace with the final hamburger icon asset once provided by design.
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.currentTheme.ink)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(Text(Strings.menu))
    }
    
    // MARK: - Logo
    
    private var logo: some View {
        Group {
            if let logo = theme.currentTheme.logo {
                logo
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(height: 20)
        .accessibilityLabel(Text(Strings.logoAccessibilityLabel))
    }
    
    // MARK: - Profile
    
    private var profileButton: some View {
        Button(action: onProfileTap) {
            ZStack(alignment: .topTrailing) {
                // TODO: Replace with the logged-in user's real avatar (async image loader)
                // once the user/session module exposes a profile image URL.
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .foregroundColor(theme.currentTheme.g300)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(theme.currentTheme.hl, lineWidth: 1.5))
                
                if hasUnreadNotifications {
                    Circle()
                        .fill(theme.currentTheme.orange)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(theme.currentTheme.snow, lineWidth: 1.5))
                        .offset(x: 1, y: -1)
                }
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .accessibilityLabel(Text(hasUnreadNotifications ? Strings.profileUnread : Strings.profile))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        TopBarView(hasUnreadNotifications: true)
        Spacer()
    }
    .background(Color(.systemGray6))
}
