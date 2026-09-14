//
//  HuntListing.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// A hunt as returned by `GET /api/v1/hunts` (the searchable listing surface).
///
/// This is a *listing* model, distinct from Home's `HuntCard` (which mirrors the
/// curated `/home` payload). They intentionally stay separate because the two
/// endpoints return different fields and may diverge further.
///
/// It reuses the shared hunt value types — `Money`, `HuntSchedule`, `HuntDuration`
/// — from `Core/Domain/HuntPrimitives.swift`.
nonisolated struct HuntListing: Identifiable, Hashable, Sendable {
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
    let guestCapacity: Int
    let isLodgingIncluded: Bool
    let imageURL: URL?
    
    /// "Fredericksburg, TX" — convenience for the card's location line.
    var locationLine: String { "\(city), \(state)" }
}

/// One page of hunt search results plus the paging metadata the backend returns.
nonisolated struct HuntSearchPage: Sendable {
    let items: [HuntListing]
    let total: Int
    let page: Int
    let pages: Int
}
