//
//  DefaultHomeRepository.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

/// Default `HomeRepository`: fetches DTOs via the remote data source and maps
/// them into domain models for the presentation layer.
final class DefaultHomeRepository: HomeRepository {

    private let remote: HomeRemoteDataSource

    init(remote: HomeRemoteDataSource) {
        self.remote = remote
    }

    func loadHome() async throws -> HomeFeed {
        let dto = try await remote.fetchHome()
        return HomeMapper.map(dto)
    }

    func loadFacets() async throws -> [FacetSection] {
        let dto = try await remote.fetchFacets()
        return FacetsMapper.map(dto)
    }
}
