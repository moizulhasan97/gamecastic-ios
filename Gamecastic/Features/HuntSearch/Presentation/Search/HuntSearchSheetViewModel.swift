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
    /// The WHERE options.
    @Published private(set) var regions: [TXRegion]
    /// Live match count for the working criteria. `nil` while (re)counting.
    @Published private(set) var matchCount: Int?
    
    private let repository: HuntSearchRepository
    private var countTask: Task<Void, Never>?
    
    init(
        repository: HuntSearchRepository,
        regionProvider: HuntRegionProvider = DefaultHuntRegionProvider(),
        initialCriteria: HuntSearchCriteria
    ) {
        self.repository = repository
        self.regions = regionProvider.regions()
        self.criteria = initialCriteria
    }
    
    func onAppear() { refreshCount() }
    
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
