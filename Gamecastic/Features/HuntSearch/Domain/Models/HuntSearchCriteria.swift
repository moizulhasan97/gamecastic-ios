//
//  HuntSearchCriteria.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 21/08/2026.
//

import Foundation

/// The single source of truth for the search bar (WHERE / SEARCH / facet filters).
///
/// This is the criteria layer that sits *above* `HuntFilterSelection`: the bar
/// sets the search *scope*, while the chip row + All Filters sheet *refine within*
/// it. Both write into one value that composes the final `HuntQuery`, so the two
/// surfaces can never drift apart.
///
/// WHEN (date range) and WHO (party size) are deliberately absent: `/hunts` has
/// no date or party params yet. When backend adds them, add the fields here and
/// append them in `query(page:limit:)` — no other layer changes.
nonisolated struct HuntSearchCriteria: Sendable, Equatable {
    
    /// WHERE — the selected region grouping (defaults to all of Texas).
    var region: TXRegion = .all
    
    /// SEARCH — free text for the `search=` param.
    var searchText: String = ""
    
    /// Facet filters from the quick chips + All Filters sheet.
    var filters: HuntFilterSelection = HuntFilterSelection()
    
    // TODO(backend – WHEN): var dateRange: DateInterval?
    // TODO(backend – WHO):  var partySize: Int?
    
    /// True when nothing has been narrowed — a clean, default search.
    var isDefault: Bool {
        region == .all && trimmedSearch.isEmpty && filters.isEmpty
    }
    
    /// Whether any refinement beyond the default region is active (drives
    /// "Clear all" affordances and the pill's active styling).
    var hasActiveCriteria: Bool { !isDefault }
    
    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Builds the `/hunts` request for this criteria.
    ///
    /// Region resolves to precise `regions=` items when it declares any, else it
    /// falls back to the coarse `state=` scope.
    func query(page: Int = 1, limit: Int = 20) -> HuntQuery {
        var query = filters.query   // facet items only
        
        // WHERE
        if region.facetRegionIDs.isEmpty {
            query.state = region.stateCode
        } else {
            query.filters.append(
                contentsOf: region.facetRegionIDs.map { HuntQuery.Item(key: "regions", value: $0) }
            )
            query.state = nil
        }
        
        // SEARCH
        let text = trimmedSearch
        query.searchText = text.isEmpty ? nil : text
        
        query.page = page
        query.limit = limit
        return query
    }
}
