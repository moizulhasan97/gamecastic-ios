//
//  HuntRegionProvider.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 21/08/2026.
//

import Foundation

/// A user-selectable location for the search bar's WHERE segment.
///
/// Options come from the `region` section of `GET /hunts/facets`, the same
/// source the Android app uses, so the picker only offers places that have
/// inventory. Each option declares how it contributes to a query:
///
/// - `stateCode` scopes the coarse `state=` param.
/// - `facetRegionIDs` are the exact `regions=City|ST` tokens, sent as repeated
///   params. When present they replace `state=` (see `HuntSearchCriteria`).
///
/// `.all` is the only client-side option.
nonisolated struct TXRegion: Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let label: String
    /// Coarse `state=` scope. `nil` = all states.
    let stateCode: String?
    /// Precise `regions=` facet values (`City|ST`) this option maps to.
    /// Empty → fall back to `stateCode` scoping only.
    let facetRegionIDs: [String]
    
    init(id: String, label: String, stateCode: String? = "TX", facetRegionIDs: [String] = []) {
        self.id = id
        self.label = label
        self.stateCode = stateCode
        self.facetRegionIDs = facetRegionIDs
    }
    
    /// Builds an option from one `region` facet option. `option.id` is the exact
    /// `regions=` token (`Amarillo|TX`); the part after `|` is the state code.
    init(facetOption option: FacetOption) {
        let parts = option.id.split(separator: "|", omittingEmptySubsequences: false)
        let state = parts.count == 2
            ? parts[1].trimmingCharacters(in: .whitespaces)
            : ""
        self.init(
            id: option.id,
            label: option.label,
            stateCode: state.isEmpty ? nil : state,
            facetRegionIDs: [option.id]
        )
    }
    
    /// The default "anywhere in Texas" scope — the starting WHERE value.
    static let all = TXRegion(id: "all", label: "All of Texas", stateCode: "TX")
}

/// Supplies the WHERE options shown in the search sheet.
protocol HuntRegionProvider: Sendable {
    /// WHERE options for a facets taxonomy. Always starts with `.all`.
    func regions(from facets: [FacetSection]) -> [TXRegion]
}

/// Builds WHERE options from the `region` facet section, in the server's order.
nonisolated struct FacetHuntRegionProvider: HuntRegionProvider {
    /// The facets section that carries `City|ST` tokens.
    static let sectionID = "region"
    
    func regions(from facets: [FacetSection]) -> [TXRegion] {
        guard let section = facets.first(where: { $0.id == Self.sectionID }) else {
            return [.all]
        }
        return [.all] + section.options.map(TXRegion.init(facetOption:))
    }
}
