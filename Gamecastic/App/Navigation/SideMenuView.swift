//
//  SideMenuView.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 31/08/2026.
//

import SwiftUI

/// The left drawer behind the top bar's hamburger — the mobile counterpart of the
/// portal's slide-out menu: category navigation plus an account entry point.
///
/// It is deliberately a *presentation* component: it owns no state and performs no
/// navigation itself, it just reports taps. Whoever presents it decides what a
/// category or the account row means, so the same drawer can be reused from a
/// screen other than Home without dragging Home's routing along with it.
struct SideMenuView: View {
    @Environment(\.theme) private var theme
    
    let isSignedIn: Bool
    let userName: String?
    var userEmail: String? = nil
    var avatarURL: URL? = nil
    let categories: [CategoryItem]
    let selectedCategoryID: String
    
    var onSelectCategory: (CategoryItem) -> Void
    var onAccountTap: () -> Void
    var onClose: () -> Void
    
    private enum Strings {
        static let browse: Localized = "Browse"
        static let close: Localized = "Close menu"
        static let signedOutTitle: Localized = "Sign in to Gamecastic"
        static let signedOutSubtitle: Localized = "Save hunts, follow gamecasters, manage bookings."
        static let account: Localized = "Your account"
        static let comingSoon: Localized = "Soon"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider().overlay(theme.currentTheme.border)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    accountCard
                    categorySection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 22)
            }
            
            Spacer(minLength: 0)
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(theme.currentTheme.snow)
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            if let logo = theme.currentTheme.logo {
                logo
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                    .accessibilityHidden(true)
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.currentTheme.ink)
                    .frame(width: 36, height: 36)
                    .background(theme.currentTheme.paper, in: Circle())
            }
            .accessibilityLabel(Text(Strings.close))
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }
    
    // MARK: - Account
    
    private var accountCard: some View {
        Button(action: onAccountTap) {
            HStack(spacing: 12) {
                AvatarView(
                    url: isSignedIn ? avatarURL : nil,
                    name: isSignedIn ? userName : nil,
                    email: isSignedIn ? userEmail : nil,
                    size: 38,
                    ringColor: isSignedIn ? theme.currentTheme.hl : nil
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    if isSignedIn {
                        Text(verbatim: userName ?? "Hunter")
                            .typography { $0.titleMedium }
                            .foregroundColor(theme.currentTheme.ink)
                        Text(Strings.account)
                            .typography { $0.bodySmall }
                            .foregroundColor(theme.currentTheme.g700)
                    } else {
                        Text(Strings.signedOutTitle)
                            .typography { $0.titleMedium }
                            .foregroundColor(theme.currentTheme.ink)
                        Text(Strings.signedOutSubtitle)
                            .typography { $0.bodySmall }
                            .foregroundColor(theme.currentTheme.g700)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.currentTheme.g500)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.currentTheme.paper, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(theme.currentTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Categories
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Strings.browse)
                .typography { $0.overlineLarge }
                .foregroundColor(theme.currentTheme.g500)
                .padding(.bottom, 6)
            
            ForEach(categories) { item in
                categoryRow(item)
            }
        }
    }
    
    private func categoryRow(_ item: CategoryItem) -> some View {
        let isSelected = item.id == selectedCategoryID
        return Button { onSelectCategory(item) } label: {
            HStack(spacing: 12) {
                item.icon
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 22)
                    .foregroundColor(isSelected ? theme.currentTheme.ink : theme.currentTheme.g700)
                
                Text(item.title)
                    .typography { $0.titleMedium }
                    .foregroundColor(item.isAvailable ? theme.currentTheme.ink : theme.currentTheme.g500)
                
                Spacer(minLength: 0)
                
                if !item.isAvailable {
                    Text(Strings.comingSoon)
                        .typography { $0.overlineMedium }
                        .foregroundColor(theme.currentTheme.g500)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(theme.currentTheme.g100, in: Capsule())
                } else if isSelected {
                    Circle()
                        .fill(theme.currentTheme.hl)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? theme.currentTheme.paper : .clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
    
    // MARK: - Footer
    
    /// The portal's drawer also lists recently viewed hunts. That needs a recents
    /// store, which in turn needs hunt detail to exist — so it lands with that slice.
    private var footer: some View {
        HStack {
            Text(verbatim: "Gamecastic \(appVersion)")
                .typography { $0.bodySmall }
                .foregroundColor(theme.currentTheme.g500)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .padding(.top, 12)
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
}

// MARK: - Presentation

extension View {
    /// Presents `content` as a left-edge drawer over the receiver, with a dimmed
    /// backdrop that dismisses on tap and a drag-to-close gesture.
    ///
    /// A drawer rather than a `.sheet` because it is navigation chrome, not a modal
    /// task: it sits beside the screen it belongs to and keeps that screen visible
    /// behind it, which a sheet's card presentation would not.
    func sideMenu<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(SideMenuModifier(isPresented: isPresented, drawer: content))
    }
}

private struct SideMenuModifier<Drawer: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder let drawer: () -> Drawer
    
    /// Live offset while the user drags the drawer closed.
    @State private var dragOffset: CGFloat = 0
    
    private let maxWidth: CGFloat = 320
    private let widthFraction: CGFloat = 0.84
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    let width = min(maxWidth, proxy.size.width * widthFraction)
                    ZStack(alignment: .leading) {
                        if isPresented {
                            Color.black.opacity(0.35)
                                .ignoresSafeArea()
                                .transition(.opacity)
                                .onTapGesture { close() }
                                .accessibilityHidden(true)
                            
                            drawer()
                                .frame(width: width)
                                .ignoresSafeArea(edges: .bottom)
                                .offset(x: dragOffset)
                                .transition(.move(edge: .leading))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            dragOffset = min(0, value.translation.width)
                                        }
                                        .onEnded { value in
                                            if value.translation.width < -width / 3 {
                                                close()
                                            } else {
                                                withAnimation(.snappy(duration: 0.2)) { dragOffset = 0 }
                                            }
                                        }
                                )
                                .shadow(color: .black.opacity(0.18), radius: 24, x: 8)
                        }
                    }
                    .animation(.snappy(duration: 0.28), value: isPresented)
                }
            }
    }
    
    private func close() {
        withAnimation(.snappy(duration: 0.28)) {
            isPresented = false
        }
        // Reset after the transition so the next presentation starts square.
        dragOffset = 0
    }
}
