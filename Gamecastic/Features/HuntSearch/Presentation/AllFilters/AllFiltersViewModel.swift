//
//  AllFiltersViewModel.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Combine
import Foundation

/// Drives the "All filters" sheet: loads the facet taxonomy, holds a *working*
/// copy of the selection, and live-previews the match count as the user toggles
/// (mirroring the web's "SHOW N MATCHES" button).
///
/// The working selection is only handed back to the caller on "Apply", so
/// dismissing the sheet discards changes.
final class AllFiltersViewModel: ObservableObject {
    
    enum FacetsState {
        case loading
        case loaded([FacetSection])
        case failed(message: String)
    }
    
    @Published private(set) var facetsState: FacetsState = .loading
    @Published private(set) var selection: HuntFilterSelection
    /// Live match count for the current working selection. `nil` while counting.
    @Published private(set) var matchCount: Int?
    
    private let repository: HuntSearchRepository
    private let scope: HuntSearchScope
    private var countTask: Task<Void, Never>?
    
    init(
        repository: HuntSearchRepository,
        initialSelection: HuntFilterSelection,
        scope: HuntSearchScope = .current
    ) {
        self.repository = repository
        self.selection = initialSelection
        self.scope = scope
    }
    
    var hasSelection: Bool { !selection.isEmpty }
    
    // MARK: - Load
    
    func load() async {
        if case .loaded = facetsState {} else { facetsState = .loading }
        do {
            let sections = try await repository.loadFacets()
            facetsState = .loaded(sections)
        } catch {
            AppLogger.warning("Facets load failed: \(error)")
            facetsState = .failed(message: "We couldn't load filters. Please try again.")
        }
        refreshCount()
    }
    
    // MARK: - Selection
    
    func isSelected(sectionID: String, optionID: String) -> Bool {
        selection.isSelected(key: HuntFacetQueryKey.key(forSectionID: sectionID), value: optionID)
    }
    
    func toggle(sectionID: String, optionID: String, singleSelect: Bool) {
        selection.toggle(
            key: HuntFacetQueryKey.key(forSectionID: sectionID),
            value: optionID,
            singleSelect: singleSelect
        )
        refreshCount()
    }
    
    func clearAll() {
        guard hasSelection else { return }
        selection.clear()
        refreshCount()
    }
    
    // MARK: - Live count
    
    private func refreshCount() {
        countTask?.cancel()
        matchCount = nil
        
        var query = selection.query(in: scope)
        query.limit = 1   // we only need `total`, not the rows
        
        countTask = Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await self.repository.searchHunts(query: query)
                if Task.isCancelled { return }
                self.matchCount = page.total
            } catch is CancellationError {
                return
            } catch {
                if Task.isCancelled { return }
                AppLogger.warning("Filter count failed: \(error)")
            }
        }
    }
}

// MARK: - Composition

extension AllFiltersViewModel {
    /// Wires the live network stack for the sheet, seeded with an existing selection.
    static func live(
        initialSelection: HuntFilterSelection,
        scope: HuntSearchScope = .current
    ) -> AllFiltersViewModel {
        let client = DefaultAPIClient(tokenProvider: { await AuthManager.shared.validAccessToken() })
        let remote = DefaultHuntSearchRemoteDataSource(client: client)
        let repository = DefaultHuntSearchRepository(remote: remote)
        return AllFiltersViewModel(repository: repository, initialSelection: initialSelection, scope: scope)
    }
}
