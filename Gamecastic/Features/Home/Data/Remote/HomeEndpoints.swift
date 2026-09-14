//
//  HomeEndpoints.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Foundation

/// The endpoints backing the Home surface.
nonisolated enum HomeEndpoints {
    /// `GET /api/v1/home` — the aggregate home feed.
    static var home: Endpoint {
        Endpoint(path: "home")
    }

    /// `GET /api/v1/hunts/facets` — the filter taxonomy.
    static var facets: Endpoint {
        Endpoint(path: "hunts/facets")
    }
}
