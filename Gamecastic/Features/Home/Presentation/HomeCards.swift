//
//  HomeCards.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import SwiftUI

// Card views for the Home surface + their shimmering skeletons.
// Dynamic, server-provided strings use `Text(verbatim:)` (they are content, not
// localizable keys — a bare `Text("...")` is ambiguous against `Text(Localized)`).

// Type comes from the theme's `TextTypography` ramp. Sites inside a `Text + Text`
// concatenation use `.font(theme.typography.<token>.font)` because they must keep
// returning `Text`; standalone views use `.typography { $0.<token> }`, which also
// carries the token's tracking and casing.

// MARK: - Card metrics

/// Shared sizing so every card in the Home rails (hunts, destinations, and their
/// skeletons) has an identical footprint.
enum HomeCardMetrics {
    static let width: CGFloat = 230
    static let imageHeight: CGFloat = 170
    static let height: CGFloat = 300
}

// MARK: - Category badge

/// A card's category badge (label + colours), derived from `huntTypes`.
///
/// TODO: `/home` has no dedicated badge field, so both the priority order and the
/// colour mapping below are inferred from the web design. Confirm with backend /
/// design whether a server-driven `badge { label, kind }` should replace this.
private struct HuntBadge {
    let label: String
    let background: Color
    let foreground: Color

    static func make(for hunt: HuntCard, theme: any AppTheme) -> HuntBadge? {
        let types = hunt.huntTypes.map { $0.lowercased() }
        func has(_ needle: String) -> Bool { types.contains { $0.contains(needle) } }

        if has("family") { return HuntBadge(label: "Family Friendly", background: theme.info, foreground: .white) }
        if has("trophy") { return HuntBadge(label: "Trophy Class", background: theme.purple, foreground: .white) }
        if has("waterfowl") { return HuntBadge(label: "Waterfowl", background: theme.hl, foreground: theme.ink) }
        if has("exotic") { return HuntBadge(label: "Exotics", background: theme.orange, foreground: .white) }
        if has("whitetail") { return HuntBadge(label: "Whitetail", background: theme.leather, foreground: .white) }
        if has("turkey") { return HuntBadge(label: "Turkey", background: theme.warn, foreground: theme.ink) }
        if let first = hunt.huntTypes.first {
            return HuntBadge(label: first, background: theme.charcoal, foreground: .white)
        }
        return nil
    }
}

// MARK: - Remote image with shimmer placeholder

/// Async image that shows a shimmering skeleton while the bytes load and a
/// neutral fill if the load fails. Always constrained + clipped to its frame.
struct RemoteImage: View {
    @Environment(\.theme) private var theme

    let url: URL?
    var cornerRadius: CGFloat = 0

    var body: some View {
        // GeometryReader gives us the resolved size so we can constrain the
        // `scaledToFill` image to *exactly* that box and clip the overflow.
        GeometryReader { proxy in
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    theme.currentTheme.g200.shimmering()
                case .failure:
                    theme.currentTheme.g200
                @unknown default:
                    theme.currentTheme.g200
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Card container

/// White, rounded, softly-shadowed card surface — the shared chrome behind every
/// hunt card (matches the web's cards-on-parchment look).
private struct CardSurface<Content: View>: View {
    @Environment(\.theme) private var theme
    let width: CGFloat
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(width: width, alignment: .leading)
            .background(theme.currentTheme.snow)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(theme.currentTheme.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}

// MARK: - Hunt card

struct HuntCardView: View {
    @Environment(\.theme) private var theme

    let hunt: HuntCard
    var width: CGFloat = HomeCardMetrics.width
    var onFavoriteToggle: () -> Void = {}

    var body: some View {
        CardSurface(width: width) {
            VStack(spacing: 0) {
                RemoteImage(url: hunt.imageURL)
                    .frame(width: width, height: HomeCardMetrics.imageHeight)
                    .overlay(alignment: .topLeading) { badge }
                    .overlay(alignment: .topTrailing) { heart }
                    .overlay(alignment: .bottomLeading) { durationPill }

                VStack(alignment: .leading, spacing: 7) {
                    creatorLine
                    Text(verbatim: hunt.title)
                        .font(theme.typography.displaySmall.font)
                        .foregroundColor(theme.currentTheme.ink)
                        // Always reserve two lines so every card is the same height,
                        // regardless of whether the title wraps.
                        .lineLimit(2, reservesSpace: true)
                    HStack(alignment: .firstTextBaseline) {
                        price
                        Spacer(minLength: 6)
                        rating
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(height: HomeCardMetrics.height)
        }
    }

    private var creatorLine: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(theme.currentTheme.leather)
                .frame(width: 18, height: 18)
            (Text(verbatim: "@").foregroundColor(theme.currentTheme.orange)
                + Text(verbatim: hunt.outfitterName.uppercased()).foregroundColor(theme.currentTheme.ink))
                .font(theme.typography.overlineLarge.font)
                .tracking(0.3)
                .lineLimit(1)
        }
    }

    private var price: some View {
        (Text(verbatim: "FROM ")
            .font(theme.typography.overlineSmall.font)
            .foregroundColor(theme.currentTheme.g500)
        + Text(verbatim: hunt.price.formatted)
            .font(theme.typography.statLarge.font)
            .foregroundColor(theme.currentTheme.ink))
            .tracking(0.3)
    }

    private var rating: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundColor(theme.currentTheme.orange)
            Text(verbatim: String(format: "%.1f (%d)", hunt.rating, hunt.reviewCount))
                .font(theme.typography.statSmall.font)
                .foregroundColor(theme.currentTheme.orange)
        }
    }

    private var heart: some View {
        Button(action: onFavoriteToggle) {
            Image(systemName: hunt.isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(hunt.isFavorite ? theme.currentTheme.orange : theme.currentTheme.ink)
                .frame(width: 30, height: 30)
                .background(theme.currentTheme.snow.opacity(0.92), in: Circle())
        }
        .padding(8)
    }

    private var durationPill: some View {
        Text(verbatim: hunt.duration.displayLabel.uppercased())
            .font(theme.typography.overlineLarge.font)
            .tracking(0.3)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(theme.currentTheme.charcoal.opacity(0.82), in: Capsule())
            .padding(8)
    }

    @ViewBuilder private var badge: some View {
        if let badge = HuntBadge.make(for: hunt, theme: theme.currentTheme) {
            Text(verbatim: badge.label.uppercased())
                .font(theme.typography.overlineMedium.font)
                .tracking(0.5)
                .foregroundColor(badge.foreground)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(badge.background, in: Capsule())
                .padding(8)
        }
    }
}

struct HuntCardSkeleton: View {
    var width: CGFloat = HomeCardMetrics.width
    var body: some View {
        CardSurface(width: width) {
            VStack(alignment: .leading, spacing: 0) {
                SkeletonView(cornerRadius: 0).frame(width: width, height: HomeCardMetrics.imageHeight)
                VStack(alignment: .leading, spacing: 8) {
                    SkeletonView().frame(width: width * 0.55, height: 11)
                    SkeletonView().frame(width: width * 0.85, height: 15)
                    SkeletonView().frame(width: width * 0.45, height: 13)
                }
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(height: HomeCardMetrics.height)
        }
    }
}

// MARK: - Gamecaster card

struct GamecasterCardView: View {
    @Environment(\.theme) private var theme

    let gamecaster: Gamecaster
    var width: CGFloat = 150

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RemoteImage(url: gamecaster.imageURL, cornerRadius: 14)
                .frame(width: width, height: 170)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(verbatim: gamecaster.displayName)
                        .font(theme.typography.displayXSmall.font)
                        .foregroundColor(theme.currentTheme.ink)
                        .lineLimit(1)
                    if gamecaster.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 11))
                            .foregroundColor(theme.currentTheme.info)
                    }
                }
                (Text(verbatim: "@").foregroundColor(theme.currentTheme.orange)
                    + Text(verbatim: gamecaster.handle.uppercased()).foregroundColor(theme.currentTheme.g700))
                    .font(theme.typography.overlineLarge.font)
                    .tracking(0.3)
                    .lineLimit(1)
            }
        }
        .frame(width: width, alignment: .leading)
    }
}

struct GamecasterCardSkeleton: View {
    var width: CGFloat = 150
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SkeletonView(cornerRadius: 14).frame(width: width, height: 170)
            SkeletonView().frame(width: width * 0.8, height: 13)
            SkeletonView().frame(width: width * 0.5, height: 11)
        }
        .frame(width: width, alignment: .leading)
    }
}

// MARK: - Destination card

struct DestinationCardView: View {
    @Environment(\.theme) private var theme

    let destination: Destination
    var width: CGFloat = HomeCardMetrics.width

    var body: some View {
        RemoteImage(url: destination.imageURL, cornerRadius: 16)
            .frame(width: width, height: HomeCardMetrics.height)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.black.opacity(0.6), .clear],
                            startPoint: .bottom,
                            endPoint: .center
                        )
                    )
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: destination.label)
                        .font(theme.typography.displaySmall.font)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text(verbatim: "\(destination.huntCount) hunts")
                        .font(theme.typography.labelSmall.font)
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(14)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(theme.currentTheme.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}

struct DestinationCardSkeleton: View {
    var width: CGFloat = HomeCardMetrics.width
    var body: some View {
        SkeletonView(cornerRadius: 16).frame(width: width, height: HomeCardMetrics.height)
    }
}
