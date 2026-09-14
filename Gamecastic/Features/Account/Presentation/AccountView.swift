//
//  AccountView.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 21/08/2026.
//

import SwiftUI

/// Router for the profile icon. Pushed onto the nav stack, it reflects the live
/// `AuthState`: signed-in → `ProfileView`, signed-out → `SignInView`, and a brief
/// spinner during `.unknown` (launch session-restore) so we don't flash the
/// sign-in screen and then swap it out.
struct AccountView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: AuthManager
    
    private enum Strings {
        static let account: Localized = "Account"
        static let profile: Localized = "Profile"
        static let signIn: Localized = "Sign in"
        static let back: Localized = "Back"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .background(theme.currentTheme.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)   // match the app's custom-bar convention
        .toastPresenter()                        // so signIn()'s toast is visible on THIS screen
    }
    
    private var title: Localized {
        switch auth.state {
        case .authenticated: return Strings.profile
        case .unauthenticated, .unknown: return Strings.signIn
        }
    }
    
    private var header: some View {
        ZStack {
            Text(title)
                .typography { $0.titleLarge }
                .foregroundColor(theme.currentTheme.ink)
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(theme.currentTheme.ink)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text(Strings.back))
                Spacer()
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 8)
        .background(theme.currentTheme.snow)
        .overlay(alignment: .bottom) {
            Rectangle().fill(theme.currentTheme.border).frame(height: 1)
        }
    }
    
    @ViewBuilder private var content: some View {
        switch auth.state {
        case .authenticated(let user):
            ProfileView(user: user)
        case .unauthenticated:
            SignInView()
        case .unknown:
            Spacer()
            ProgressView().tint(theme.currentTheme.orange)
            Spacer()
        }
    }
}
