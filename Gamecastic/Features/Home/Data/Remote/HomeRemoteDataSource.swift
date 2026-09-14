//
//  HomeRemoteDataSource.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

/// Fetches raw Home DTOs from the network. Kept behind a protocol so the
/// repository can be tested with an in-memory source.
protocol HomeRemoteDataSource: Sendable {
    func fetchHome() async throws -> HomeFeedDTO
    func fetchFacets() async throws -> FacetsDTO
}

/// `APIClient`-backed implementation.
final class DefaultHomeRemoteDataSource: HomeRemoteDataSource {

    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchHome() async throws -> HomeFeedDTO {
        try await client.send(HomeEndpoints.home, as: HomeFeedDTO.self)
    }

    func fetchFacets() async throws -> FacetsDTO {
        try await client.send(HomeEndpoints.facets, as: FacetsDTO.self)
    }
}
