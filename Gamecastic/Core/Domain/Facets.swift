//
//  Facets.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 31/08/2026.
//

import Foundation

// The filter taxonomy from `GET /api/v1/hunts/facets`.
//
// Facets are app-wide, not a HuntSearch detail: the Home hero's quick chips, the
// search results chip bar and the All Filters sheet all read the same taxonomy,
// and a Hunt Detail "similar hunts" surface would too. Hence Core.
//
// Each `FacetOption.id` is the EXACT query token to send to `/hunts` — never
// hardcode option values, always drive the UI and the request off these.

/// A filter group returned by `GET /api/v1/hunts/facets`.
nonisolated struct FacetSection: Identifiable, Hashable, Sendable {
    let id: String
    let label: String
    let isSingleSelect: Bool
    let options: [FacetOption]
}

/// A single selectable value inside a `FacetSection`, with its match count.
nonisolated struct FacetOption: Identifiable, Hashable, Sendable {
    let id: String
    let label: String
    let count: Int
}
