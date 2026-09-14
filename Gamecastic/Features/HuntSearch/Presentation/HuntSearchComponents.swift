//
//  HuntSearchComponents.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import SwiftUI

// Building blocks for the hunt search surface: the filter bar + chip, the
// full-width result card + its skeleton, and the empty state.
//
// Dynamic, server-provided strings use `Text(verbatim:)`; static UI copy uses
// `Text(Localized("…"))` (a bare `Text("…")` is ambiguous against the
// `Text(Localized)` initializer in this codebase).

// Type comes from the theme's `TextTypography` ramp — see the note in `HomeCards`
// on when to use `.font(theme.typography.…)` versus `.typography { … }`.

// MARK: - Filter bar

/// The horizontally-scrolling quick-filter row with a "Clear all" affordance.
struct HuntFilterBar: View {
    @Environment(\.theme) private var theme
    
    let filters: [HuntFilter]
    let isSelected: (HuntFilter) -> Bool
    let hasActiveFilters: Bool
    let onToggle: (HuntFilter) -> Void
    let onClearAll: () -> Void
    /// When provided, an "All filters" pill is shown ahead of the quick chips.
    var onOpenAllFilters: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 10) {
            header
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if let onOpenAllFilters {
                        allFiltersPill(action: onOpenAllFilters)
                    }
                    ForEach(filters) { filter in
                        HuntFilterChip(
                            filter: filter,
                            isSelected: isSelected(filter),
                            action: { onToggle(filter) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 2)
            }
        }
        .padding(.top, 6)
        .padding(.bottom, 4)
        .background(theme.currentTheme.paper)
    }
    
    private var header: some View {
        HStack {
            Text(Localized("Filters"))
                .font(theme.typography.statSmall.font)
                .tracking(0.4)
                .foregroundColor(theme.currentTheme.g700)
                .textCase(.uppercase)
            
            Spacer()
            
            if hasActiveFilters {
                Button(action: onClearAll) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                        Text(Localized("Clear all"))
                            .font(theme.typography.titleSmall.font)
                    }
                    .foregroundColor(theme.currentTheme.orange)
                }
                .accessibilityLabel(Text(Localized("Clear all filters")))
            }
        }
        .padding(.horizontal, 16)
    }
    
    /// Leading "All filters" pill (outlined, with a sliders icon).
    private func allFiltersPill(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 12, weight: .semibold))
                Text(Localized("All filters"))
                    .font(theme.typography.titleMedium.font)
            }
            .foregroundColor(theme.currentTheme.ink)
            .padding(.horizontal, 14)
            .frame(height: 38)
            .background(theme.currentTheme.snow, in: Capsule())
            .overlay(Capsule().stroke(theme.currentTheme.ink, lineWidth: 1.5))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(Localized("Open all filters")))
    }
}

// MARK: - Filter chip

/// A single selectable filter pill: icon + label, filled when selected.
///
/// Colours, border and font come from `theme.categoryChipStyle.style(for: .filter)`
/// — the same provider `CategorySelector` uses — so a chip variant is defined once
/// in the design system rather than per view.
struct HuntFilterChip: View {
    @Environment(\.theme) private var theme
    
    let filter: HuntFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.systemImage)
                    .font(.system(size: 12, weight: .semibold))
                Text(filter.title)
                    .font(style.font)
                    .lineLimit(1)
            }
            .foregroundColor(foreground)
            .padding(.horizontal, 14)
            .frame(height: 38)
            .background(background, in: Capsule())
            .overlay(
                Capsule().stroke(borderColor, lineWidth: style.borderWidth)
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
        .accessibilityLabel(Text(filter.title))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    private var style: any CategoryChipStyleProtocol {
        theme.categoryChipStyle.style(for: .filter)
    }
    private var foreground: Color {
        isSelected ? style.titleSelectedColor : style.titleColor
    }
    private var background: Color {
        isSelected ? style.backgroundSelectedColor : style.backgroundColor
    }
    private var borderColor: Color {
        isSelected ? style.borderSelectedColor : style.borderColor
    }
}

// MARK: - Result card

/// A full-width hunt listing card — the mobile-native counterpart to the web's
/// grid tiles. Image on top with overlays; details below.
struct HuntListingCard: View {
    @Environment(\.theme) private var theme
    
    let listing: HuntListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RemoteImage(url: listing.imageURL)
                .frame(height: 190)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .topLeading) { categoryBadge }
                .overlay(alignment: .bottomLeading) { durationPill }
            
            VStack(alignment: .leading, spacing: 8) {
                outfitterLine
                Text(verbatim: listing.title)
                    .font(theme.typography.displaySmall.font)
                    .foregroundColor(theme.currentTheme.ink)
                    .lineLimit(2)
                
                metaLine
                
                HStack(alignment: .firstTextBaseline) {
                    price
                    Spacer(minLength: 8)
                    rating
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(theme.currentTheme.snow)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(theme.currentTheme.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
    
    private var outfitterLine: some View {
        HStack(spacing: 6) {
            Circle().fill(theme.currentTheme.leather).frame(width: 18, height: 18)
            (Text(verbatim: "@").foregroundColor(theme.currentTheme.orange)
             + Text(verbatim: listing.outfitterName.uppercased()).foregroundColor(theme.currentTheme.g700))
            .font(theme.typography.overlineLarge.font)
            .tracking(0.3)
            .lineLimit(1)
        }
    }
    
    private var metaLine: some View {
        HStack(spacing: 10) {
            label(icon: "mappin.and.ellipse", text: listing.locationLine)
            label(icon: "person.2.fill", text: "\(listing.guestCapacity)")
            if listing.isLodgingIncluded {
                label(icon: "house.fill", text: "Lodging")
            }
        }
        .font(theme.typography.labelSmall.font)
        .foregroundColor(theme.currentTheme.g700)
        .lineLimit(1)
    }
    
    private func label(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 10))
            Text(verbatim: text)
        }
    }
    
    private var price: some View {
        (Text(verbatim: "FROM ")
            .font(theme.typography.overlineSmall.font)
            .foregroundColor(theme.currentTheme.g500)
         + Text(verbatim: listing.price.formatted)
            .font(theme.typography.statLarge.font)
            .foregroundColor(theme.currentTheme.ink)
         + Text(verbatim: " / person")
            .font(theme.typography.labelXSmall.font)
            .foregroundColor(theme.currentTheme.g500))
        .tracking(0.2)
    }
    
    private var rating: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 11))
                .foregroundColor(theme.currentTheme.orange)
            Text(verbatim: String(format: "%.1f (%d)", listing.rating, listing.reviewCount))
                .font(theme.typography.statSmall.font)
                .foregroundColor(theme.currentTheme.orange)
        }
    }
    
    @ViewBuilder private var categoryBadge: some View {
        if let first = listing.huntTypes.first {
            Text(verbatim: first.uppercased())
                .font(theme.typography.overlineMedium.font)
                .tracking(0.5)
                .foregroundColor(.white)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(theme.currentTheme.charcoal.opacity(0.82), in: Capsule())
                .padding(10)
        }
    }
    
    private var durationPill: some View {
        Text(verbatim: listing.duration.displayLabel.uppercased())
            .font(theme.typography.overlineLarge.font)
            .tracking(0.3)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(theme.currentTheme.orange.opacity(0.92), in: Capsule())
            .padding(10)
    }
}

// MARK: - Result skeleton

/// Shimmering placeholder that mirrors `HuntListingCard`'s footprint.
struct HuntListingCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SkeletonView(cornerRadius: 0).frame(height: 190).frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: 10) {
                SkeletonView().frame(width: 130, height: 11)
                SkeletonView().frame(maxWidth: .infinity).frame(height: 18)
                SkeletonView().frame(width: 180, height: 12)
                SkeletonView().frame(width: 120, height: 14)
            }
            .padding(14)
        }
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

// MARK: - Empty state

/// Shown when a filter combination returns no matches.
struct HuntSearchEmptyView: View {
    @Environment(\.theme) private var theme
    
    let hasActiveFilters: Bool
    let onClearAll: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "binoculars")
                .font(.system(size: 46, weight: .regular))
                .foregroundColor(theme.currentTheme.g500)
            
            Text(Localized("No hunts match your filters"))
                .font(theme.typography.displayMedium.font)
                .foregroundColor(theme.currentTheme.ink)
                .multilineTextAlignment(.center)
            
            Text(Localized("Try removing a filter or two to see more hunts."))
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.currentTheme.g700)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if hasActiveFilters {
                AppButton(
                    title: "Clear all filters",
                    type: .primary,
                    width: .padded(padding: 28),
                    height: 46,
                    action: onClearAll
                )
                .fixedSize()
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, 20)
    }
}
