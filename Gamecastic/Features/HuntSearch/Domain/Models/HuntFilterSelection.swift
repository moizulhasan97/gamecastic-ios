//
//  HuntFilterSelection.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// The single source of truth for "what filters are currently applied".
///
/// It is keyed at the **query-parameter level** (`key` = the `/hunts` param
/// name, `value` = a facet `option.id`), NOT by quick-filter catalog id or by
/// facet section. That's deliberate: the quick-filter chips and the All Filters
/// sheet are two different *views* of the same underlying selection, so both
/// read and write this one type and stay perfectly in sync — a quick "Trophy"
/// chip and the "Trophy" option in All Filters resolve to the same
/// `species=Trophy` entry.
nonisolated struct HuntFilterSelection: Sendable, Equatable {
    
    /// `queryKey` → selected values. e.g. `["species": ["Family Friendly", "Trophy"]]`.
    private(set) var valuesByKey: [String: Set<String>] = [:]
    
    init(valuesByKey: [String: Set<String>] = [:]) {
        self.valuesByKey = valuesByKey.filter { !$0.value.isEmpty }
    }
    
    // MARK: Queries
    
    var isEmpty: Bool { valuesByKey.isEmpty }
    
    /// Total number of selected values across all keys (for the "N selected" badge).
    var count: Int { valuesByKey.values.reduce(0) { $0 + $1.count } }
    
    func isSelected(key: String, value: String) -> Bool {
        valuesByKey[key]?.contains(value) ?? false
    }
    
    // MARK: Mutation
    
    /// Toggles a value for a key. When `singleSelect` is true (e.g. the `sort`
    /// facet), selecting a value replaces any other value under that key.
    mutating func toggle(key: String, value: String, singleSelect: Bool) {
        var set = valuesByKey[key] ?? []
        if set.contains(value) {
            set.remove(value)
        } else if singleSelect {
            set = [value]
        } else {
            set.insert(value)
        }
        if set.isEmpty {
            valuesByKey.removeValue(forKey: key)
        } else {
            valuesByKey[key] = set
        }
    }
    
    mutating func clear() {
        valuesByKey.removeAll()
    }
    
    // MARK: Serialisation
    
    /// A `HuntQuery` for this selection. Keys and values are sorted so the same
    /// selection always produces the same request (stable caching / dedupe).
    var query: HuntQuery {
        var items: [HuntQuery.Item] = []
        for key in valuesByKey.keys.sorted() {
            for value in (valuesByKey[key] ?? []).sorted() {
                items.append(HuntQuery.Item(key: key, value: value))
            }
        }
        return HuntQuery(filters: items)
    }
    
    /// The query for this selection within a location `scope` (applies `state=`).
    /// This is the one seam that composes user filters with the app's scope.
    func query(in scope: HuntSearchScope) -> HuntQuery {
        var query = self.query
        query.state = scope.state
        return query
    }
}

// MARK: - Facet section → query key

/// Maps a `/hunts/facets` `section.id` to the `/hunts` query-parameter name.
///
/// This mapping is NOT derivable (it isn't plain pluralisation — `price` →
/// `priceBands`), and the facets payload doesn't expose it, so it lives here as
/// the single place the client hard-codes it.
/// TODO(backend): ask for a `param` field per facet section so this can be dropped.
nonisolated enum HuntFacetQueryKey {
    static func key(forSectionID sectionID: String) -> String {
        switch sectionID {
        case "species":   return "species"
        case "region":    return "regions"
        case "outfitter": return "outfitters"
        case "schedule":  return "schedules"
        case "duration":  return "durations"
        case "lodging":   return "lodging"
        case "price":     return "priceBands"
        case "trust":     return "trust"
        case "sort":      return "sort"
        default:          return sectionID   // forward-compatible fallback
        }
    }
}
