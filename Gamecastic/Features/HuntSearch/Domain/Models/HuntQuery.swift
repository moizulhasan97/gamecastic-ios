//
//  HuntQuery.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// A fully-resolved description of one `GET /api/v1/hunts` request.
///
/// This is deliberately decoupled from `HuntFilter` (a presentation type): the
/// view model flattens the selected chips into plain `key`/`value` pairs, so the
/// data layer never depends on anything UI-facing and this value can safely
/// cross actor boundaries.
///
/// ### Serialisation rules (captured from the web contract, 2026-08-19)
/// - Multiple values for the **same** key are sent as **repeated** query items
///   (`?species=Family+Friendly&species=Waterfowl`), *not* comma-joined.
/// - `search`, `state`, `page`, `limit` are appended when present.
nonisolated struct HuntQuery: Sendable, Equatable {
    
    /// One `key=value` contribution to the query string.
    struct Item: Sendable, Equatable {
        let key: String
        let value: String
    }
    
    /// Selected facet filters (species, schedules, durations, …).
    var filters: [Item] = []
    
    /// Free-text search (`search=` param). Not wired to UI yet — reserved so the
    /// search box can be added later without touching the data layer.
    var searchText: String? = nil
    
    /// Coarse location scope (`state=` param, 2-letter code). `nil` returns all
    /// states.
    var state: String? = nil
    
    /// 1-based page index.
    var page: Int = 1
    
    /// Page size.
    var limit: Int = 20
    
    /// The ordered query items for this request, ready for `Endpoint(queryItems:)`.
    var queryItems: [URLQueryItem] {
        var items = filters.map { URLQueryItem(name: $0.key, value: $0.value) }
        if let searchText, !searchText.isEmpty {
            items.append(URLQueryItem(name: "search", value: searchText))
        }
        if let state, !state.isEmpty {
            items.append(URLQueryItem(name: "state", value: state))
        }
        items.append(URLQueryItem(name: "page", value: String(page)))
        items.append(URLQueryItem(name: "limit", value: String(limit)))
        return items
    }
}
