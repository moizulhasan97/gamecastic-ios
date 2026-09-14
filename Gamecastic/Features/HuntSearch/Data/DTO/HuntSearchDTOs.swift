//
//  HuntSearchDTOs.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

// Wire-format types for `GET /api/v1/hunts`. These mirror the JSON exactly;
// normalisation happens in `HuntSearchMapper`. Unlisted keys in the payload
// (description, animals, outfitterId, isActive, createdAt, lat/long, …) are
// intentionally not decoded — `Decodable` ignores keys we don't declare.

/// The `data` payload of `GET /api/v1/hunts`.
nonisolated struct HuntsPageDTO: Decodable, Sendable {
    let items: [HuntListingDTO]
    let total: Int
    let page: Int
    let pages: Int
}

nonisolated struct HuntListingDTO: Decodable, Sendable {
    let id: String
    let outfitterName: String
    let title: String
    let city: String
    let state: String
    let huntTypes: [String]
    let schedule: String        // "Morning" | "Afternoon" | "FullDay"
    let duration: Int           // structured value, e.g. 3
    let durationUnit: String    // "Days" | "Hours"
    let guestCapacity: Int
    let lodgingOption: String   // "Included" | "None"
    let pricePerPerson: Double
    let imageUrls: [String]
    let rating: Double
    let reviewCount: Int
}
