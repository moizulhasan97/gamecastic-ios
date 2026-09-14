//
//  HuntSearchEndpoints.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Foundation

/// The endpoints backing the hunt search surface.
nonisolated enum HuntSearchEndpoints {
    static func hunts(query: HuntQuery) -> Endpoint {
        Endpoint(path: "hunts", queryItems: query.queryItems)
    }
    static var facets: Endpoint {
        Endpoint(path: "hunts/facets")
    }
}
