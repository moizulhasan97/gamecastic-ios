//
//  HomeDTOs.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

// Wire-format types. These mirror the JSON exactly (including quirks such as the
// pre-formatted `durationLabel`); normalisation happens in `HomeMapper`.

// MARK: - GET /api/v1/home

nonisolated struct HomeFeedDTO: Decodable, Sendable {
    let featuredHero: HuntCardDTO?
    let featuredSide: [HuntCardDTO]
    let trendingHunts: [HuntCardDTO]
    let trendingGamecasters: [GamecasterDTO]
    let popularHunts: [HuntCardDTO]
    let destinations: [DestinationDTO]
    let styleRails: [StyleRailDTO]
    let followingGamecasters: [GamecasterDTO]
    let favoriteHunts: [HuntCardDTO]
}

nonisolated struct HuntCardDTO: Decodable, Sendable {
    let id: String
    let title: String
    let outfitterName: String
    let city: String
    let state: String
    let pricePerPerson: Double
    let rating: Double
    let reviewCount: Int
    let schedule: String        // "Morning" | "Afternoon" | "FullDay"
    let durationLabel: String   // "3 Days" | "6 Hours" (display string)
    let huntTypes: [String]
    let imageUrl: String
    let isFavorite: Bool
}

nonisolated struct GamecasterDTO: Decodable, Sendable {
    let id: String
    let handle: String
    let displayName: String
    let bio: String
    let verificationState: String   // e.g. "Verified"
    let visibilityState: String     // e.g. "Public"
    let imageUrl: String
    let isFollowing: Bool
}

nonisolated struct DestinationDTO: Decodable, Sendable {
    let id: String
    let label: String
    let state: String
    let huntCount: Int
    let imageUrl: String
}

nonisolated struct StyleRailDTO: Decodable, Sendable {
    let id: String
    let label: String
    let items: [HuntCardDTO]
}

// Facet DTOs (`FacetsDTO` and friends) now live in `Core/Data/FacetsDTO.swift`,
// alongside `FacetsMapper` — the taxonomy is shared, not Home's.
