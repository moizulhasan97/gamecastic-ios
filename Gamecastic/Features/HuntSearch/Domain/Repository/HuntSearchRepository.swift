//
//  HuntSearchRepository.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// Domain-facing gateway for the hunt search surface.
///
/// The presentation layer depends only on this protocol, so the data source
/// (network, cache, mock) can change without touching the view model.
protocol HuntSearchRepository: Sendable {
    func searchHunts(query: HuntQuery) async throws -> HuntSearchPage
    func loadFacets() async throws -> [FacetSection]
}
