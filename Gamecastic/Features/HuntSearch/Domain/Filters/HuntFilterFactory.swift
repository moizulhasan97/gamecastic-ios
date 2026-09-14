//
//  HuntFilterFactory.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// Produces the set of quick filters shown in the hunt search bar.
///
/// This is the seam that lets the *source* of the filters change without
/// touching the UI or view model. Today the only implementation is a static,
/// hand-curated catalog (`DefaultHuntFilterFactory`). Later, "All filters" can
/// add a facets-driven implementation (built from `GET /hunts/facets`) behind
/// this same protocol.
protocol HuntFilterFactory {
    /// The ordered quick filters, top → bottom of preference / left → right on screen.
    func quickFilters() -> [HuntFilter]
}

/// The single source of truth for the quick-filter row.
///
/// ────────────────────────────────────────────────────────────────────────
///  TO ADD / REMOVE / REORDER A QUICK FILTER: edit the array below. Nothing
///  else needs to change — the bar, selection, and query building all derive
///  from this list.
/// ────────────────────────────────────────────────────────────────────────
///
/// `queryKey` + `value` must match the API contract exactly:
///
/// | Facet     | queryKey      | example value (facets `option.id`)          |
/// |-----------|---------------|---------------------------------------------|
/// | species   | `species`     | `Family Friendly`, `Waterfowl`, `Trophy`    |
/// | schedule  | `schedules`   | `Morning`, `FullDay`, `Afternoon`           |
/// | duration  | `durations`   | `Days:1`, `Days:2`, `Hours:5`               |
/// | lodging   | `lodging`     | `Included`, `None`                          |
/// | price     | `priceBands`  | `under-500`, `500-1500`, `1500-3000`        |
///
/// NOTE: quick filters are multi-select on mobile (unlike the web's single-active
/// chips) — combining them produces repeated query params, which the API supports.
struct DefaultHuntFilterFactory: HuntFilterFactory {
    
    func quickFilters() -> [HuntFilter] {
        [
            HuntFilter(
                id: "species.family-friendly",
                title: "Family Friendly",
                systemImage: "figure.2.and.child.holdinghands",
                queryKey: "species",
                value: "Family Friendly"
            ),
            HuntFilter(
                id: "species.waterfowl",
                title: "Waterfowl",
                systemImage: "bird.fill",
                queryKey: "species",
                value: "Waterfowl"
            ),
            HuntFilter(
                id: "species.trophy",
                title: "Trophy",
                systemImage: "trophy.fill",
                queryKey: "species",
                value: "Trophy"
            ),
            HuntFilter(
                id: "schedule.morning",
                title: "Morning",
                systemImage: "sunrise.fill",
                queryKey: "schedules",
                value: "Morning"
            ),
            HuntFilter(
                id: "schedule.full-day",
                title: "Full Day",
                systemImage: "sun.max.fill",
                queryKey: "schedules",
                value: "FullDay"
            ),
            HuntFilter(
                id: "duration.day-trip",
                title: "Day Trip",
                systemImage: "clock.fill",
                queryKey: "durations",
                value: "Days:1"
            ),
            HuntFilter(
                id: "duration.weekend",
                title: "Weekend",
                systemImage: "calendar",
                queryKey: "durations",
                value: "Days:2"
            ),
            HuntFilter(
                id: "lodging.included",
                title: "Lodging Included",
                systemImage: "house.fill",
                queryKey: "lodging",
                value: "Included"
            ),
            HuntFilter(
                id: "price.under-500",
                title: "Under $500",
                systemImage: "dollarsign.circle.fill",
                queryKey: "priceBands",
                value: "under-500"
            ),
        ]
    }
}
