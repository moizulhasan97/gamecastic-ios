//
//  HuntSearchViewModel.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import Combine
import Foundation

final class HuntSearchViewModel: ObservableObject {
    
    enum ViewState {
        case idle
        case loading
        case loaded([HuntListing])
        case empty
        case failed(message: String)
    }
    
    @Published private(set) var state: ViewState = .idle
    /// The quick-filter chip catalog (source of truth = `HuntFilterFactory`).
    @Published private(set) var filters: [HuntFilter]
    /// The single source of truth for the whole search: WHERE + SEARCH + facets.
    @Published private(set) var criteria: HuntSearchCriteria
    /// Total matches for the current query, which may exceed the loaded pages.
    /// nil until the first successful response.
    @Published private(set) var totalCount: Int?
    /// True while a *subsequent* page is in flight (the first page uses `state`).
    @Published private(set) var isLoadingMore = false
    /// Set when an append fails, so the footer can offer a retry without
    /// destroying the pages already on screen.
    @Published private(set) var loadMoreFailed = false
    
    private let repository: HuntSearchRepository
    private let pageSize: Int
    
    /// Page currently loaded (1-based) and how many the backend says exist.
    private var loadedPage = 0
    private var totalPages = 0
    
    private var searchTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    
    init(
        repository: HuntSearchRepository,
        filterFactory: HuntFilterFactory,
        initialCriteria: HuntSearchCriteria = HuntSearchCriteria(),
        pageSize: Int = 20
    ) {
        self.repository = repository
        self.filters = filterFactory.quickFilters()
        self.criteria = initialCriteria
        self.pageSize = pageSize
    }
    
    // MARK: - Facet filters (quick chips + All Filters)
    
    /// Whether any facet filter is active — drives the chip bar's "Clear all".
    /// (Region + search live in the pill, so they don't count here.)
    var hasActiveFilters: Bool { !criteria.filters.isEmpty }
    
    /// The current facet selection, for seeding the All Filters sheet.
    var selection: HuntFilterSelection { criteria.filters }
    
    func isSelected(_ filter: HuntFilter) -> Bool {
        criteria.filters.isSelected(key: filter.queryKey, value: filter.value)
    }
    
    func toggle(_ filter: HuntFilter) {
        criteria.filters.toggle(key: filter.queryKey, value: filter.value, singleSelect: false)
        performSearch()
    }
    
    /// Replaces the facet selection (from All Filters "Apply") and refreshes.
    func apply(_ newSelection: HuntFilterSelection) {
        criteria.filters = newSelection
        performSearch()
    }
    
    func clearAll() {
        guard hasActiveFilters else { return }
        criteria.filters.clear()
        performSearch()
    }
    
    // MARK: - Search bar (WHERE + SEARCH)
    
    /// Applies the full criteria from the search sheet (region + text; facets
    /// are carried through by the sheet) and refreshes.
    func applySearch(_ newCriteria: HuntSearchCriteria) {
        criteria = newCriteria
        performSearch()
    }
    
    // MARK: - Lifecycle
    
    func onAppear() {
        guard case .idle = state else { return }
        performSearch()
    }
    
    func retry() {
        performSearch()
    }
    
    // MARK: - Pagination
    
    /// Items already on screen. Derived from `state` so there is exactly one
    /// copy of the list — no shadow array to drift out of sync.
    private var loadedItems: [HuntListing] {
        if case .loaded(let items) = state { return items }
        return []
    }
    
    /// Whether the backend has pages we haven't fetched.
    var hasMorePages: Bool { loadedPage > 0 && loadedPage < totalPages }
    
    /// Called as cards appear. Fires one page ahead of the end of the list so the
    /// next batch is usually already there by the time the user reaches it.
    ///
    /// Safe to call on every `onAppear`: it no-ops unless `item` is inside the
    /// trailing window, and a page is already in flight or exhausted.
    func loadMoreIfNeeded(currentItem item: HuntListing) {
        let items = loadedItems
        guard let index = items.firstIndex(of: item) else { return }
        let threshold = max(items.count - 4, 0)
        guard index >= threshold else { return }
        loadNextPage()
    }
    
    /// Retry entry point for the footer after a failed append.
    func retryLoadMore() {
        loadMoreFailed = false
        loadNextPage()
    }
    
    private func loadNextPage() {
        guard hasMorePages, !isLoadingMore, !loadMoreFailed else { return }
        
        let nextPage = loadedPage + 1
        let query = criteria.query(page: nextPage, limit: pageSize)
        let existing = loadedItems
        
        isLoadingMore = true
        loadMoreTask = Task { [weak self] in
            guard let self else { return }
            defer { self.isLoadingMore = false }
            do {
                let page = try await self.repository.searchHunts(query: query)
                if Task.isCancelled { return }
                
                // A new search may have landed while this was in flight; only
                // append if we are still on the page we asked for.
                guard self.loadedPage == nextPage - 1 else { return }
                
                // Defensive de-dupe: a row inserted server-side between page
                // fetches would otherwise appear twice and break `Identifiable`.
                var seen = Set(existing.map(\.id))
                let fresh = page.items.filter { seen.insert($0.id).inserted }
                
                self.loadedPage = page.page
                self.totalPages = page.pages
                self.totalCount = page.total
                self.state = .loaded(existing + fresh)
            } catch is CancellationError {
                return
            } catch {
                if Task.isCancelled { return }
                AppLogger.warning("Hunt search page \(nextPage) failed: \(error)")
                self.loadMoreFailed = true
            }
        }
    }
    
    // MARK: - Search
    
    private func performSearch() {
        searchTask?.cancel()
        loadMoreTask?.cancel()
        isLoadingMore = false
        loadMoreFailed = false
        loadedPage = 0
        totalPages = 0
        
        let query = criteria.query(page: 1, limit: pageSize)
        searchTask = Task { [weak self] in
            guard let self else { return }
            self.state = .loading
            do {
                let page = try await self.repository.searchHunts(query: query)
                if Task.isCancelled { return }
                self.totalCount = page.total
                self.loadedPage = page.page
                self.totalPages = page.pages
                self.state = page.items.isEmpty ? .empty : .loaded(page.items)
            } catch is CancellationError {
                return
            } catch {
                if Task.isCancelled { return }
                AppLogger.warning("Hunt search failed: \(error)")
                self.state = .failed(message: "We couldn't load hunts. Please try again.")
            }
        }
    }
}

extension HuntSearchViewModel {
    static func live(initialCriteria: HuntSearchCriteria = HuntSearchCriteria()) -> HuntSearchViewModel {
        let client = DefaultAPIClient(tokenProvider: { await AuthManager.shared.validAccessToken() })
        let remote = DefaultHuntSearchRemoteDataSource(client: client)
        let repository = DefaultHuntSearchRepository(remote: remote)
        return HuntSearchViewModel(
            repository: repository,
            filterFactory: DefaultHuntFilterFactory(),
            initialCriteria: initialCriteria
        )
    }
}
