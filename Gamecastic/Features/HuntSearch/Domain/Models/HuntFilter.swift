//
//  HuntFilter.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// A single tappable quick-filter shown in the hunt search filter bar.
///
/// A `HuntFilter` is a *presentation-facing* description of one filter chip:
/// what to draw (`title`, `systemImage`) and what it means to the API
/// (`queryKey` + `value`). The catalog of these — order, which ones exist — is
/// owned entirely by `HuntFilterFactory`, so this type stays a dumb value.
///
/// `value` MUST be the exact token the backend expects (i.e. the facets
/// `option.id`, e.g. `"Family Friendly"`, `"FullDay"`, `"Days:2"`,
/// `"under-500"`), and `queryKey` the exact query parameter name (e.g.
/// `"species"`, `"schedules"`, `"durations"`, `"priceBands"`). See
/// `HuntQuery` for how selected filters are serialised.
struct HuntFilter: Identifiable, Equatable {
    /// Stable, unique id (also used to track selection). Not sent to the API.
    let id: String
    /// Chip label. `Localized` (not a raw `String`) to match the app's
    /// localisation convention — see `Text+Extension` / `Localized`.
    let title: Localized
    /// SF Symbol name drawn ahead of the label.
    let systemImage: String
    /// The `/hunts` query parameter name this filter contributes to.
    let queryKey: String
    /// The exact token sent as the parameter's value (a facets `option.id`).
    let value: String
    
    // `Localized` is not `Equatable`, so equate by identity — matching the
    // pattern used by `CategoryItem`.
    static func == (lhs: HuntFilter, rhs: HuntFilter) -> Bool { lhs.id == rhs.id }
}
