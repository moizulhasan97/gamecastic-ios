//
//  HuntSearchRemoteDataSource.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// Fetches raw hunt-search DTOs from the network. Kept behind a protocol so the
/// repository can be tested with an in-memory source.
protocol HuntSearchRemoteDataSource: Sendable {
    func fetchHunts(query: HuntQuery) async throws -> HuntsPageDTO
    func fetchFacets() async throws -> FacetsDTO
}

final class DefaultHuntSearchRemoteDataSource: HuntSearchRemoteDataSource {
    private let client: APIClient
    init(client: APIClient) { self.client = client }
    
    func fetchHunts(query: HuntQuery) async throws -> HuntsPageDTO {
        try await client.send(HuntSearchEndpoints.hunts(query: query), as: HuntsPageDTO.self)
    }
    // `FacetsDTO` is shared app-wide taxonomy and lives in `Core/Data`.
    func fetchFacets() async throws -> FacetsDTO {
        try await client.send(HuntSearchEndpoints.facets, as: FacetsDTO.self)
    }
}
