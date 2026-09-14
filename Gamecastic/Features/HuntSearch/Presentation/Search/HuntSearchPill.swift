//
//  HuntSearchPill.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 25/08/2026.
//

import SwiftUI

/// The collapsed search entry. Tapping opens `HuntSearchSheet`.
///
/// - `.expanded` — the Home hero entry: a prominent WHERE + SEARCH bar with the
///   orange action circle (the mobile-native stand-in for the web command bar).
/// - `.compact` — a slim summary capsule for the top of the results screen, so
///   the active criteria stay visible and re-editable.
struct HuntSearchPill: View {
    @Environment(\.theme) private var theme
    
    enum Style { case expanded, compact }
    
    let criteria: HuntSearchCriteria
    var style: Style = .expanded
    let action: () -> Void
    
    var body: some View {
        switch style {
        case .expanded: expanded
        case .compact:  compact
        }
    }
    
    // MARK: - Expanded (Home)
    
    private var expanded: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                column(title: "WHERE", value: criteria.region.label)
                divider
                column(title: "SEARCH", value: searchValue, isPlaceholder: criteria.searchText.isEmpty)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(theme.currentTheme.orange, in: Circle())
                    .padding(.leading, 6)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(theme.currentTheme.snow)
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(theme.currentTheme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(Localized("Search hunts")))
        .accessibilityValue(Text(verbatim: summary))
    }
    
    private func column(title: String, value: String, isPlaceholder: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: title)
                .typography { $0.overlineSmall }
                .foregroundColor(theme.currentTheme.g500)
            Text(verbatim: value)
                .typography { $0.titleSmall }
                .foregroundColor(isPlaceholder ? theme.currentTheme.g500 : theme.currentTheme.ink)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(theme.currentTheme.border)
            .frame(width: 1, height: 26)
            .padding(.horizontal, 6)
    }
    
    // MARK: - Compact (results header)
    
    private var compact: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(theme.currentTheme.orange)
                Text(verbatim: summary)
                    .typography { $0.titleMedium }
                    .foregroundColor(theme.currentTheme.ink)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.currentTheme.g700)
            }
            .padding(.horizontal, 16)
            .frame(height: 46)
            .background(theme.currentTheme.snow, in: Capsule())
            .overlay(Capsule().stroke(theme.currentTheme.border, lineWidth: 1))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(Localized("Edit search")))
        .accessibilityValue(Text(verbatim: summary))
    }
    
    // MARK: - Text
    
    private var searchValue: String {
        criteria.searchText.isEmpty ? "Search hunts" : criteria.searchText
    }
    
    /// One-line summary, e.g. "Hill Country" or "Hill Country · whitetail".
    private var summary: String {
        let text = criteria.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? criteria.region.label : "\(criteria.region.label) · \(text)"
    }
}
