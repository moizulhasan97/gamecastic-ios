//
//  HomeMapper.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

/// Single seam between the wire format (DTOs) and the domain models.
///
/// All backend quirks (display strings, enum spellings, absolute image URLs) are
/// normalised here, so a contract change touches this file only.
nonisolated enum HomeMapper {

    // MARK: Feed

    static func map(_ dto: HomeFeedDTO) -> HomeFeed {
        HomeFeed(
            hero: dto.featuredHero.map(map),
            heroAlternates: dto.featuredSide.map(map),
            trendingHunts: dto.trendingHunts.map(map),
            trendingGamecasters: dto.trendingGamecasters.map(map),
            popularHunts: dto.popularHunts.map(map),
            destinations: dto.destinations.map(map),
            styleRails: dto.styleRails.map(map),
            following: dto.followingGamecasters.map(map),
            favorites: dto.favoriteHunts.map(map)
        )
    }

    // MARK: Hunt

    static func map(_ dto: HuntCardDTO) -> HuntCard {
        HuntCard(
            id: dto.id,
            title: dto.title,
            outfitterName: dto.outfitterName,
            city: dto.city,
            state: dto.state,
            price: Money(amount: dto.pricePerPerson, currencyCode: "USD"),
            rating: dto.rating,
            reviewCount: dto.reviewCount,
            schedule: HuntSchedule(raw: dto.schedule),
            duration: parseDuration(dto.durationLabel),
            huntTypes: dto.huntTypes,
            imageURL: URL(string: dto.imageUrl),
            isFavorite: dto.isFavorite
        )
    }

    // MARK: Gamecaster

    static func map(_ dto: GamecasterDTO) -> Gamecaster {
        Gamecaster(
            id: dto.id,
            handle: dto.handle,
            displayName: dto.displayName,
            bio: dto.bio,
            isVerified: dto.verificationState.caseInsensitiveCompare("Verified") == .orderedSame,
            isPublic: dto.visibilityState.caseInsensitiveCompare("Public") == .orderedSame,
            imageURL: URL(string: dto.imageUrl),
            isFollowing: dto.isFollowing
        )
    }

    // MARK: Destination

    static func map(_ dto: DestinationDTO) -> Destination {
        Destination(
            id: dto.id,
            label: dto.label,
            state: dto.state,
            huntCount: dto.huntCount,
            imageURL: URL(string: dto.imageUrl)
        )
    }

    // MARK: Style rail

    static func map(_ dto: StyleRailDTO) -> StyleRail {
        StyleRail(
            id: dto.id,
            label: dto.label,
            items: dto.items.map(map)
        )
    }

    // Facet mapping moved to `FacetsMapper` in `Core/Data/FacetsDTO.swift`.

    // MARK: Helpers

    /// Defensive parse of "3 Days" / "6 Hours" until the backend sends a
    /// structured duration ({ value, unit }).
    private static func parseDuration(_ label: String) -> HuntDuration {
        let value = Int(label.split(separator: " ").first ?? "") ?? 0
        let lowered = label.lowercased()
        let unit: HuntDuration.Unit =
            lowered.contains("hour") ? .hour :
            lowered.contains("day")  ? .day  : .unknown
        return HuntDuration(value: value, unit: unit, displayLabel: label)
    }
}
