//
//  ProfileView.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import SwiftUI

/// Logged-in state of `AccountView`: identity, the account hub's sections, logout.
///
/// The sections mirror the portal's `/profile` tabs (trips · saved · profile ·
/// payments · notifications, plus identity and security) so the two products
/// describe an account the same way. Each row's destination is a separate slice
/// with its own endpoints; until a slice lands, its row reports "coming soon" the
/// same way the unavailable category chips do, rather than opening an empty screen.
struct ProfileView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var auth: AuthManager
    
    let user: AuthenticatedUser
    
    private enum Strings {
        static let fallbackName: Localized = "Hunter"
        static let logOut: Localized = "Log out"
        static let sectionHunting: Localized = "Your hunting"
        static let sectionAccount: Localized = "Account"
        static let sectionPreferences: Localized = "Preferences"
        static let comingSoon: Localized = "%@ — coming soon"
    }
    
    /// One row in the hub. `isAvailable` is the seam: flip it to `true` and give the
    /// row a destination as each slice lands.
    private struct AccountSection: Identifiable {
        let id: String
        let title: Localized
        let subtitle: Localized
        let icon: String
        var isAvailable: Bool = false
    }
    
    private var huntingSections: [AccountSection] {
        [
            AccountSection(id: "saved", title: "Saved hunts", subtitle: "Hunts you've hearted", icon: "heart"),
            AccountSection(id: "following", title: "Following", subtitle: "Gamecasters you follow", icon: "person.2"),
            AccountSection(id: "trips", title: "Trips & bookings", subtitle: "Requests, confirmations, past trips", icon: "calendar")
        ]
    }
    
    private var accountSections: [AccountSection] {
        [
            AccountSection(id: "details", title: "Personal details", subtitle: "Name, contact, emergency contact", icon: "person.text.rectangle"),
            AccountSection(id: "verification", title: "Verification", subtitle: "ID, hunting licence, hunter education", icon: "checkmark.seal"),
            AccountSection(id: "payments", title: "Payment methods", subtitle: "Cards used at checkout", icon: "creditcard")
        ]
    }
    
    private var preferenceSections: [AccountSection] {
        [
            AccountSection(id: "notifications", title: "Notifications", subtitle: "Booking updates and payment alerts", icon: "bell"),
            AccountSection(id: "security", title: "Security", subtitle: "Two-factor authentication", icon: "lock")
        ]
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 26) {
                identityHeader
                sectionGroup(Strings.sectionHunting, huntingSections)
                sectionGroup(Strings.sectionAccount, accountSections)
                sectionGroup(Strings.sectionPreferences, preferenceSections)
                logOutButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Identity
    
    private var identityHeader: some View {
        VStack(spacing: 12) {
            AvatarView(
                url: user.pictureURL,
                name: user.name,
                email: user.email,
                size: 88,
                ringColor: theme.currentTheme.hl,
                ringWidth: 2
            )
            
            Text(verbatim: user.name ?? Strings.fallbackName.resolve())
                .typography { $0.headingMedium }
                .foregroundColor(theme.currentTheme.ink)
            
            if let email = user.email {
                Text(verbatim: email)
                    .typography { $0.bodyMedium }
                    .foregroundColor(theme.currentTheme.g500)
            }
        }
    }
    
    // MARK: - Sections
    
    private func sectionGroup(_ title: Localized, _ sections: [AccountSection]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .typography { $0.overlineLarge }
                .foregroundColor(theme.currentTheme.g500)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                    sectionRow(section)
                    if index < sections.count - 1 {
                        Divider()
                            .overlay(theme.currentTheme.border)
                            .padding(.leading, 56)
                    }
                }
            }
            .background(theme.currentTheme.snow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(theme.currentTheme.border, lineWidth: 1)
            )
        }
    }
    
    private func sectionRow(_ section: AccountSection) -> some View {
        Button { select(section) } label: {
            HStack(spacing: 14) {
                Image(systemName: section.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.currentTheme.g700)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(section.title)
                        .typography { $0.titleMedium }
                        .foregroundColor(theme.currentTheme.ink)
                    Text(section.subtitle)
                        .typography { $0.bodySmall }
                        .foregroundColor(theme.currentTheme.g500)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 8)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.currentTheme.g300)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func select(_ section: AccountSection) {
        guard section.isAvailable else {
            ToastManager.shared.show(Strings.comingSoon.resolve(section.title.resolve()))
            return
        }
        // Destinations land with their slices — see the account-hub epic.
    }
    
    // MARK: - Log out
    
    private var logOutButton: some View {
        Button(action: { auth.signOut() }) {
            Text(Strings.logOut)
                .typography { $0.titleLarge }
                .foregroundColor(theme.currentTheme.risk)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.currentTheme.risk.opacity(0.4), lineWidth: 1)
                )
        }
    }
}
