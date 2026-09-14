//
//  HuntSearchMapper.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// Single seam between the `/hunts` wire format (DTOs) and domain models.
/// All backend quirks (enum spellings, absolute image URLs, duration shape) are
/// normalised here, so a contract change touches this file only.
nonisolated enum HuntSearchMapper {
    
    static func map(_ dto: HuntsPageDTO) -> HuntSearchPage {
        HuntSearchPage(
            items: dto.items.map(map),
            total: dto.total,
            page: dto.page,
            pages: dto.pages
        )
    }
    
    static func map(_ dto: HuntListingDTO) -> HuntListing {
        HuntListing(
            id: dto.id,
            title: dto.title,
            outfitterName: dto.outfitterName,
            city: dto.city,
            state: dto.state,
            price: Money(amount: dto.pricePerPerson, currencyCode: "USD"),
            rating: dto.rating,
            reviewCount: dto.reviewCount,
            schedule: HuntSchedule(raw: dto.schedule),
            duration: mapDuration(value: dto.duration, unit: dto.durationUnit),
            huntTypes: dto.huntTypes,
            guestCapacity: dto.guestCapacity,
            isLodgingIncluded: dto.lodgingOption.caseInsensitiveCompare("Included") == .orderedSame,
            imageURL: dto.imageUrls.first.flatMap(URL.init(string:))
        )
    }
    
    /// Unlike `/home` (which sends a pre-formatted "3 Days" label), `/hunts`
    /// sends structured `duration` + `durationUnit`, so we build the display
    /// label ourselves and keep it grammatically simple.
    private static func mapDuration(value: Int, unit: String) -> HuntDuration {
        let lowered = unit.lowercased()
        let parsedUnit: HuntDuration.Unit =
        lowered.hasPrefix("hour") ? .hour :
        lowered.hasPrefix("day")  ? .day  : .unknown
        
        // "1 Day" not "1 Days".
        let singular = String(unit.dropLast(unit.count > 1 && unit.hasSuffix("s") ? 1 : 0))
        let unitLabel = value == 1 ? singular : unit
        return HuntDuration(value: value, unit: parsedUnit, displayLabel: "\(value) \(unitLabel)")
    }
}
