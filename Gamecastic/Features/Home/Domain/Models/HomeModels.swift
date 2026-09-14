//
//  HomeModels.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

// MARK: - Home feed

/// The full set of content rendered on the Home surface.
///
/// Mirrors the aggregate returned by `GET /api/v1/home`: one network call
/// produces one `HomeFeed`, which drives the whole screen.
nonisolated struct HomeFeed: Sendable {
    let hero: HuntCard?
    let heroAlternates: [HuntCard]        // "swap into main" side cards
    let trendingHunts: [HuntCard]
    let trendingGamecasters: [Gamecaster]
    let popularHunts: [HuntCard]
    let destinations: [Destination]
    let styleRails: [StyleRail]
    let following: [Gamecaster]           // populated for authenticated users
    let favorites: [HuntCard]             // populated for authenticated users
}

// MARK: - Hunt

/// A bookable hunt listing as shown on a card.
nonisolated struct HuntCard: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let outfitterName: String
    let city: String
    let state: String
    let price: Money
    let rating: Double
    let reviewCount: Int
    let schedule: HuntSchedule
    let duration: HuntDuration
    let huntTypes: [String]
    let imageURL: URL?
    let isFavorite: Bool
}

// `Money`, `HuntSchedule` and `HuntDuration` now live in `Core/Domain/HuntPrimitives.swift`
// — they are shared by every hunt surface, not Home's to own.

// MARK: - Gamecaster

/// A creator / host who runs hunts.
nonisolated struct Gamecaster: Identifiable, Hashable, Sendable {
    let id: String
    let handle: String
    let displayName: String
    let bio: String
    let isVerified: Bool
    let isPublic: Bool
    let imageURL: URL?
    let isFollowing: Bool
}

// MARK: - Destination

/// A place-based collection of hunts ("Gamecasts by destination").
nonisolated struct Destination: Identifiable, Hashable, Sendable {
    let id: String
    let label: String
    let state: String
    let huntCount: Int
    let imageURL: URL?
}

// MARK: - Style rail

/// A titled, curated collection of hunts ("By style: …").
nonisolated struct StyleRail: Identifiable, Hashable, Sendable {
    let id: String
    let label: String
    let items: [HuntCard]
}

// Facet types (`FacetSection` / `FacetOption`) now live in `Core/Domain/Facets.swift`.
