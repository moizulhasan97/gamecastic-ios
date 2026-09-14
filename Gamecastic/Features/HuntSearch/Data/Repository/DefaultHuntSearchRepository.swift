//
//  DefaultHuntSearchRepository.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// Default `HuntSearchRepository`: fetches DTOs via the remote data source and
/// maps them into domain models for the presentation layer.
final class DefaultHuntSearchRepository: HuntSearchRepository {
    private let remote: HuntSearchRemoteDataSource
    init(remote: HuntSearchRemoteDataSource) { self.remote = remote }
    
    func searchHunts(query: HuntQuery) async throws -> HuntSearchPage {
        let dto = try await remote.fetchHunts(query: query)
        return HuntSearchMapper.map(dto)
    }
    func loadFacets() async throws -> [FacetSection] {
        let dto = try await remote.fetchFacets()
        return FacetsMapper.map(dto)
    }
}
