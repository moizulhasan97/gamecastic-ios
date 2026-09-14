//
//  HomeRepository.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

/// Domain-facing gateway for everything the Home surface needs.
///
/// The presentation layer depends only on this protocol, so the data source
/// (network, cache, mock) can change without touching view models or views.
protocol HomeRepository: Sendable {
    /// Loads the full home feed (`GET /api/v1/home`).
    func loadHome() async throws -> HomeFeed

    /// Loads the filter taxonomy (`GET /api/v1/hunts/facets`).
    func loadFacets() async throws -> [FacetSection]
}
