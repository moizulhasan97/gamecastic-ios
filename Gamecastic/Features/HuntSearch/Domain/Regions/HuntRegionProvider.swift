//
//  HuntRegionProvider.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 21/08/2026.
//

import Foundation

/// A named, user-selectable location for the search bar's WHERE segment.
///
/// Gamecastic is Texas-only today, and the web labels WHERE with *regions*
/// ("Hill Country") rather than the city-level values the `/hunts` `regions`
/// facet exposes (`Amarillo|TX`). So a region is modelled as a curated grouping
/// that declares *how it contributes to a query*:
///
/// - `stateCode` scopes the coarse `state=` param (all TX regions → `TX`).
/// - `facetRegionIDs` — when known — are the exact `regions=City|ST` values that
///   make up this grouping, sent as repeated params for precise filtering.
///
/// Today `facetRegionIDs` is empty for every grouping (we don't yet have the
/// city→region map from backend), so WHERE currently scopes to `state=TX`. The
/// moment backend provides a region grouping (or we hardcode city lists), fill
/// `facetRegionIDs` here and querying becomes precise — no other layer changes.
/// TODO(backend): add a region-group concept (or per-city region tags) to facets.
nonisolated struct TXRegion: Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let label: String
    /// Coarse `state=` scope. `nil` = all states.
    let stateCode: String?
    /// Precise `regions=` facet values (`City|ST`) this grouping maps to.
    /// Empty → fall back to `stateCode` scoping only.
    let facetRegionIDs: [String]
    
    init(id: String, label: String, stateCode: String? = "TX", facetRegionIDs: [String] = []) {
        self.id = id
        self.label = label
        self.stateCode = stateCode
        self.facetRegionIDs = facetRegionIDs
    }
    
    /// The default "anywhere in Texas" scope — the starting WHERE value.
    static let all = TXRegion(id: "all", label: "All of Texas", stateCode: "TX")
}

/// Supplies the curated WHERE options. Protocol-first so a facets/backend-driven
/// implementation can replace the hardcoded list later without touching callers —
/// the same pattern as `HuntFilterFactory`.
protocol HuntRegionProvider: Sendable {
    func regions() -> [TXRegion]
}

/// Hardcoded Texas regions. Edit this one array to add/reorder WHERE options.
/// `facetRegionIDs` are intentionally empty until the city→region map is known.
nonisolated struct DefaultHuntRegionProvider: HuntRegionProvider {
    func regions() -> [TXRegion] {
        [
            .all,
            TXRegion(id: "hill-country",   label: "Hill Country"),
            TXRegion(id: "south-texas",    label: "South Texas"),
            TXRegion(id: "panhandle",      label: "Panhandle"),
            TXRegion(id: "piney-woods",    label: "Piney Woods"),
            TXRegion(id: "gulf-coast",     label: "Gulf Coast"),
            TXRegion(id: "west-texas",     label: "West Texas"),
        ]
    }
}
