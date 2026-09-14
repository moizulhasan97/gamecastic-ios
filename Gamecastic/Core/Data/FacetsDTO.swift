//
//  FacetsDTO.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 31/08/2026.
//

import Foundation

// Wire format for `GET /api/v1/hunts/facets`, plus its mapper.
//
// Shared rather than feature-owned: the facets endpoint is one taxonomy consumed
// by several features, so neither Home nor HuntSearch should own its DTO.

nonisolated struct FacetsDTO: Decodable, Sendable {
    let sections: [FacetSectionDTO]
}

nonisolated struct FacetSectionDTO: Decodable, Sendable {
    let id: String
    let label: String
    let singleSelect: Bool
    let options: [FacetOptionDTO]
}

nonisolated struct FacetOptionDTO: Decodable, Sendable {
    let id: String
    let label: String
    let count: Int
}

/// The single seam between the facets wire format and the domain.
nonisolated enum FacetsMapper {

    static func map(_ dto: FacetsDTO) -> [FacetSection] {
        dto.sections.map(map)
    }

    static func map(_ dto: FacetSectionDTO) -> FacetSection {
        FacetSection(
            id: dto.id,
            label: dto.label,
            isSingleSelect: dto.singleSelect,
            options: dto.options.map { option in
                FacetOption(id: option.id, label: option.label, count: option.count)
            }
        )
    }
}
