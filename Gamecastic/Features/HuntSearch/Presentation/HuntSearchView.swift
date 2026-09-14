//
//  HuntSearchView.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import SwiftUI

struct HuntSearchView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: HuntSearchViewModel
    @State private var showingAllFilters = false
    @State private var showingSearch = false
    
    private let showsBackButton: Bool
    
    init(viewModel: HuntSearchViewModel = .live(), showsBackButton: Bool = false) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.showsBackButton = showsBackButton
    }
    
    var body: some View {
        VStack(spacing: 0) {
            titleHeader
            
            HuntSearchPill(criteria: viewModel.criteria, style: .compact) {
                showingSearch = true
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            
            HuntFilterBar(
                filters: viewModel.filters,
                isSelected: viewModel.isSelected,
                hasActiveFilters: viewModel.hasActiveFilters,
                onToggle: viewModel.toggle,
                onClearAll: viewModel.clearAll,
                onOpenAllFilters: { showingAllFilters = true }
            )
            
            Divider().overlay(theme.currentTheme.border)
            
            content
        }
        .background(theme.currentTheme.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task { viewModel.onAppear() }
        .sheet(isPresented: $showingSearch) {
            HuntSearchSheet(
                viewModel: .live(initialCriteria: viewModel.criteria),
                onApply: { applied in viewModel.applySearch(applied) }
            )
        }
        .sheet(isPresented: $showingAllFilters) {
            AllFiltersView(
                viewModel: .live(initialSelection: viewModel.selection),
                onApply: { applied in viewModel.apply(applied) }
            )
        }
    }
    
    private var titleHeader: some View {
        HStack(alignment: .center, spacing: 10) {
            if showsBackButton {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(theme.currentTheme.ink)
                        .frame(width: 36, height: 36)
                        .background(theme.currentTheme.snow, in: Circle())
                        .overlay(Circle().stroke(theme.currentTheme.border, lineWidth: 1))
                }
                .accessibilityLabel(Text(Localized("Back")))
            }
            Text(Localized("Explore hunts"))
                .typography { $0.displayMedium }
                .foregroundColor(theme.currentTheme.ink)
            Spacer()
            resultCount
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder private var resultCount: some View {
        if case .loaded(let hunts) = viewModel.state {
            Text(verbatim: "\(viewModel.totalCount ?? hunts.count) hunts")
                .typography { $0.titleSmall }
                .foregroundColor(theme.currentTheme.g700)
        }
    }
    
    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingList
        case .loaded(let hunts):
            resultsList(hunts)
        case .empty:
            HuntSearchEmptyView(hasActiveFilters: viewModel.hasActiveFilters, onClearAll: viewModel.clearAll)
            Spacer(minLength: 0)
        case .failed(let message):
            errorView(message)
            Spacer(minLength: 0)
        }
    }
    
    private func resultsList(_ hunts: [HuntListing]) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(hunts) { hunt in
                    HuntListingCard(listing: hunt)
                        // `LazyVStack` only builds rows as they come into view, so
                        // this fires once per row and one screen early — see
                        // `loadMoreIfNeeded`, which no-ops outside the trailing window.
                        .onAppear { viewModel.loadMoreIfNeeded(currentItem: hunt) }
                }
                paginationFooter
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    /// Footer for the infinite list: a skeleton while the next page loads, an
    /// inline retry if it failed, and an end-of-results marker once exhausted.
    @ViewBuilder private var paginationFooter: some View {
        if viewModel.loadMoreFailed {
            VStack(spacing: 10) {
                Text(Localized("We couldn't load more hunts."))
                    .typography { $0.labelMedium }
                    .foregroundColor(theme.currentTheme.g700)
                Button(action: viewModel.retryLoadMore) {
                    Text(Localized("Try again"))
                        .typography { $0.titleSmall }
                        .foregroundColor(theme.currentTheme.orange)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        } else if viewModel.isLoadingMore {
            HuntListingCardSkeleton()
        } else if !viewModel.hasMorePages {
            Text(Localized("That's every hunt matching your search."))
                .typography { $0.bodySmall }
                .foregroundColor(theme.currentTheme.g500)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
        }
    }
    
    private var loadingList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { _ in HuntListingCardSkeleton() }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .allowsHitTesting(false)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 44))
                .foregroundColor(theme.currentTheme.g500)
            Text(verbatim: message)
                .typography { $0.labelLarge }
                .foregroundColor(theme.currentTheme.g700)
                .multilineTextAlignment(.center)
            AppButton(title: "Try again", type: .primary, width: .padded(padding: 28), height: 46, action: viewModel.retry)
                .fixedSize()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, 20)
    }
}

#if DEBUG
private struct PreviewHuntSearchRepository: HuntSearchRepository {
    func searchHunts(query: HuntQuery) async throws -> HuntSearchPage {
        if query.filters.contains(where: { $0.key == "priceBands" }) {
            return HuntSearchPage(items: [], total: 0, page: 1, pages: 0)
        }
        let items = (0..<4).map { index in
            HuntListing(
                id: "preview-\(index)", title: "Hill Country Trophy Whitetail",
                outfitterName: "Lone Star Backcountry", city: "Fredericksburg", state: "TX",
                price: Money(amount: 1850, currencyCode: "USD"), rating: 4.98, reviewCount: 86,
                schedule: HuntSchedule(raw: "Morning"),
                duration: HuntDuration(value: 3, unit: .day, displayLabel: "3 Days"),
                huntTypes: ["Whitetail", "Trophy"], guestCapacity: 4, isLodgingIncluded: true, imageURL: nil
            )
        }
        return HuntSearchPage(items: items, total: items.count, page: 1, pages: 1)
    }
    func loadFacets() async throws -> [FacetSection] {
        [
            FacetSection(id: "species", label: "Species", isSingleSelect: false, options: [
                FacetOption(id: "Family Friendly", label: "Family Friendly", count: 5),
                FacetOption(id: "Waterfowl", label: "Waterfowl", count: 5),
                FacetOption(id: "Trophy", label: "Trophy", count: 4),
            ]),
            FacetSection(id: "price", label: "Price · per hunter", isSingleSelect: false, options: [
                FacetOption(id: "under-500", label: "Under $500", count: 4),
                FacetOption(id: "500-1500", label: "$500–$1,500", count: 7),
            ]),
        ]
    }
}

#Preview {
    HuntSearchView(
        viewModel: HuntSearchViewModel(repository: PreviewHuntSearchRepository(), filterFactory: DefaultHuntFilterFactory())
    )
}
#endif
