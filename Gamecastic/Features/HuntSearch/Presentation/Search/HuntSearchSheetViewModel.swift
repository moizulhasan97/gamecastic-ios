//
//  HuntSearchSheetViewModel.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 25/08/2026.
//

import Combine
import Foundation

/// Drives the search bar sheet (WHERE + SEARCH). Holds a *working* copy of the
/// criteria and live-previews the match count as the user edits it — the same
/// "SHOW N MATCHES" affordance as the All Filters sheet.
///
/// The working criteria carries the caller's active facet filters through
/// untouched, so the previewed count reflects the *full* query (region + search
/// + facets), not just the two segments edited here. Only region + searchText are
/// mutated; on Apply the whole criteria is handed back.
final class HuntSearchSheetViewModel: ObservableObject {
    
    /// Working copy. Bound directly by the sheet (region taps + the search field).
    @Published var criteria: HuntSearchCriteria
    /// The WHERE options: "All of Texas" plus one option per `region` facet.
    @Published private(set) var regions: [TXRegion]
    /// Live match count for the working criteria. `nil` while (re)counting.
    @Published private(set) var matchCount: Int?
    
    private let repository: HuntSearchRepository
    private let regionProvider: HuntRegionProvider
    private var countTask: Task<Void, Never>?
    
    init(
        repository: HuntSearchRepository,
        regionProvider: HuntRegionProvider = FacetHuntRegionProvider(),
        initialCriteria: HuntSearchCriteria
    ) {
        self.repository = repository
        self.regionProvider = regionProvider
        // Until facets arrive: "All of Texas" plus whatever is already applied,
        // so an applied region is never missing from the picker.
        self.regions = HuntSearchSheetViewModel.merging([.all], keeping: initialCriteria.region)
        self.criteria = initialCriteria
    }
    
    func onAppear() { refreshCount() }
    
    /// Loads the WHERE options from `GET /hunts/facets`. On failure the
    /// placeholder options stay, so the sheet still works with "All of Texas".
    func loadRegions() async {
        do {
            let facets = try await repository.loadFacets()
            regions = Self.merging(regionProvider.regions(from: facets), keeping: criteria.region)
        } catch {
            if Task.isCancelled || error is CancellationError { return }
            AppLogger.warning("Search regions failed: \(error)")
        }
    }
    
    /// `options`, plus `selected` appended when the server no longer lists it.
    private static func merging(_ options: [TXRegion], keeping selected: TXRegion) -> [TXRegion] {
        options.contains(selected) ? options : options + [selected]
    }
    
    var canReset: Bool {
        criteria.region != .all ||
        !criteria.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Editing
    
    func selectRegion(_ region: TXRegion) {
        criteria.region = region
        refreshCount()
    }
    
    func isSelected(_ region: TXRegion) -> Bool { criteria.region == region }
    
    /// Call from the search field's `.onChange` — debounced inside `refreshCount`.
    func searchTextChanged() { refreshCount() }
    
    /// Resets only the search-bar segments (region + text); facet filters persist.
    func reset() {
        criteria.region = .all
        criteria.searchText = ""
        refreshCount()
    }
    
    // MARK: - Live count
    
    private func refreshCount() {
        countTask?.cancel()
        matchCount = nil
        
        let query = criteria.query(page: 1, limit: 1)   // only `total` is needed
        countTask = Task { [weak self] in
            guard let self else { return }
            // Debounce: coalesces rapid typing / taps into one request.
            try? await Task.sleep(nanoseconds: 300_000_000)
            if Task.isCancelled { return }
            do {
                let page = try await self.repository.searchHunts(query: query)
                if Task.isCancelled { return }
                self.matchCount = page.total
            } catch is CancellationError {
                return
            } catch {
                if Task.isCancelled { return }
                AppLogger.warning("Search count failed: \(error)")
            }
        }
    }
}

// MARK: - Composition

extension HuntSearchSheetViewModel {
    static func live(initialCriteria: HuntSearchCriteria) -> HuntSearchSheetViewModel {
        let client = DefaultAPIClient(tokenProvider: { await AuthManager.shared.validAccessToken() })
        let remote = DefaultHuntSearchRemoteDataSource(client: client)
        let repository = DefaultHuntSearchRepository(remote: remote)
        return HuntSearchSheetViewModel(repository: repository, initialCriteria: initialCriteria)
    }
}
