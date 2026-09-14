//
//  HuntSearchScope.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// Where hunt search is scoped geographically. Kept separate from
/// `HuntFilterSelection` because location is a *scope* the app decides, not a
/// filter the user toggles.
///
/// This is the single source of truth for the `state` query param. Gamecastic
/// operates in Texas only today, so `current` pins `state=TX` (matching web).
///
/// ── When more states come online, the change is localised to this file: ──
///   • support everything → set `state` to `nil` (drops the param, returns all)
///   • let the user choose → build a `HuntSearchScope(state:)` from a location
///     picker and pass it into `HuntSearchViewModel` / `AllFiltersViewModel`
///     (both already accept a `scope` parameter, defaulting to `.current`).
/// Nothing else on the client needs to change — every query is composed through
/// `HuntFilterSelection.query(in:)`.
nonisolated struct HuntSearchScope: Sendable, Equatable {
    /// 2-letter state code to scope to, or `nil` for "all states".
    var state: String?
    
    /// The scope used everywhere unless a view model is given a different one.
    static let current = HuntSearchScope(state: "TX")
}
