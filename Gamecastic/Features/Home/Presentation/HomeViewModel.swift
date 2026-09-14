//
//  HomeViewModel.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import Combine
import Foundation

/// Drives the Home surface: loads the feed + facets and exposes a single,
/// observable view state for the view to render.
///
/// Uses `ObservableObject` / `@Published` to stay consistent with the rest of
/// the app (e.g. `AppThemeManager`).
final class HomeViewModel: ObservableObject {
    
    /// The lifecycle of the Home content.
    enum ViewState {
        case idle
        case loading
        case loaded(HomeFeed)
        case failed(message: String)
    }
    
    @Published private(set) var state: ViewState = .idle
    @Published private(set) var facets: [FacetSection] = []
    
    private let repository: HomeRepository
    
    init(repository: HomeRepository) {
        self.repository = repository
    }
    
    /// Loads once on first appearance; safe to call repeatedly.
    func onAppear() async {
        guard case .idle = state else { return }
        await load()
    }
    
    /// Explicit reload (pull-to-refresh / retry).
    func refresh() async {
        await load()
    }
    
    private func load() async {
        state = .loading
        do {
            // Independent requests → run concurrently so both are in flight at once.
            async let feed = repository.loadHome()
            async let sections = repository.loadFacets()
            
            let (loadedFeed, loadedFacets) = try await (feed, sections)
            facets = loadedFacets
            state = .loaded(loadedFeed)
        } catch {
            AppLogger.warning("Home load failed: \(error)")
            state = .failed(message: "We couldn't load the home feed. Pull to retry.")
        }
    }
}

// MARK: - Composition

extension HomeViewModel {
    /// Convenience factory wiring the live network stack.
    /// Replace `DefaultAPIClient()`'s token provider once auth lands.
    static func live() -> HomeViewModel {
        let client = DefaultAPIClient(tokenProvider: { await AuthManager.shared.validAccessToken() })
        let remote = DefaultHomeRemoteDataSource(client: client)
        let repository = DefaultHomeRepository(remote: remote)
        return HomeViewModel(repository: repository)
    }
}
