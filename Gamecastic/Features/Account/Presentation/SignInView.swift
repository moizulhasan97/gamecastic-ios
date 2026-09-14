//
//  SignInView.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import SwiftUI

/// Logged-out state of `AccountView`. Both actions kick off the SAME hosted
/// Authorization Code flow — the identity server's page is where the user
/// chooses to log in or create an account — so there are no native forms here.
struct SignInView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var auth: AuthManager
    
    private enum Strings {
        static let title: Localized = "Sign in to Gamecastic"
        static let subtitle: Localized = "Save favorites, follow gamecasters, and manage your booked hunts."
        static let signIn: Localized = "Sign in"
        static let createPrompt: Localized = "New to Gamecastic?"
        static let createAction: Localized = "Create an account"
        static let secureNote: Localized = "Sign in opens a secure Gamecastic page."
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            if let logo = theme.currentTheme.logo {
                logo.resizable().scaledToFit().frame(height: 28)
                    .padding(.bottom, 24)
            }
            
            Text(Strings.title)
                .typography { $0.headingLarge }
                .foregroundColor(theme.currentTheme.ink)
                .multilineTextAlignment(.center)
            
            Text(Strings.subtitle)
                .typography { $0.bodyLarge }
                .foregroundColor(theme.currentTheme.g500)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 8)
            
            Spacer()
            
            VStack(spacing: 16) {
                AppButton(title: Strings.signIn, type: .primary) {
                    Task { await auth.signIn() }
                }
                
                Button(action: { Task { await auth.signIn() } }) {
                    HStack(spacing: 4) {
                        Text(Strings.createPrompt)
                            .foregroundColor(theme.currentTheme.g500)
                        Text(Strings.createAction)
                            .foregroundColor(theme.currentTheme.orange)
                    }
                    .typography { $0.labelMedium }
                }
                
                Text(Strings.secureNote)
                    .typography { $0.bodySmall }
                    .foregroundColor(theme.currentTheme.g300)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
