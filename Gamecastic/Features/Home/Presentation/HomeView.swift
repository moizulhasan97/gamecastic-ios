//
//  HomeView.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import SwiftUI

/// The Home surface: the first screen users land on. Renders the aggregate
/// `/home` feed as a set of horizontal rails, with a shimmering skeleton while
/// loading and a retry state on failure.
struct HomeView: View {
    
    @Environment(\.theme) private var theme
    @StateObject private var viewModel: HomeViewModel
    @State private var selectedCategory = "trending"
    @State private var criteria = HuntSearchCriteria()
    @State private var showingAllFilters = false
    @State private var showingSearch = false
    @State private var showingResults = false
    @State private var pendingShowResults = false
    @EnvironmentObject private var auth: AuthManager
    @State private var showingAccount = false
    @State private var showingMenu = false
    /// Which of the featured hunts is currently promoted into the hero.
    /// `nil` = whatever the feed says. Set by the "swap into main" cards.
    @State private var promotedHeroID: String?
    
    private let quickFilters: [HuntFilter] = DefaultHuntFilterFactory().quickFilters()
    
    init(viewModel: HomeViewModel = .live()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBarView(
                    hasUnreadNotifications: false,
                    isSignedIn: auth.isAuthenticated,
                    avatarURL: auth.currentUser?.pictureURL,
                    userName: auth.currentUser?.name,
                    userEmail: auth.currentUser?.email,
                    onMenuTap: { withAnimation(.snappy(duration: 0.28)) { showingMenu = true } },
                    onProfileTap: { showingAccount = true }
                )
                CategorySelector(items: categoryItems, selection: $selectedCategory)
                content
            }
            .background(theme.currentTheme.paper.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)          // Home uses its own TopBarView
            .toastPresenter()
            .sideMenu(isPresented: $showingMenu) {
                SideMenuView(
                    isSignedIn: auth.isAuthenticated,
                    userName: auth.currentUser?.name,
                    userEmail: auth.currentUser?.email,
                    avatarURL: auth.currentUser?.pictureURL,
                    categories: categoryItems,
                    selectedCategoryID: selectedCategory,
                    onSelectCategory: handleMenuCategory,
                    onAccountTap: {
                        showingMenu = false
                        showingAccount = true
                    },
                    onClose: { withAnimation(.snappy(duration: 0.28)) { showingMenu = false } }
                )
            }
            .task { await viewModel.onAppear() }
            .navigationDestination(isPresented: $showingResults) {
                HuntSearchView(viewModel: .live(initialCriteria: criteria), showsBackButton: true)
            }
            .navigationDestination(isPresented: $showingAccount) {
                AccountView()
            }
            .sheet(isPresented: $showingSearch, onDismiss: {
                if pendingShowResults { pendingShowResults = false; showingResults = true }
            }) {
                HuntSearchSheet(viewModel: .live(initialCriteria: criteria), onApply: { applied in
                    criteria = applied
                    pendingShowResults = true
                })
            }
            .sheet(isPresented: $showingAllFilters, onDismiss: {
                if pendingShowResults { pendingShowResults = false; showingResults = true }
            }) {
                AllFiltersView(viewModel: .live(initialSelection: criteria.filters), onApply: { applied in
                    criteria.filters = applied
                    pendingShowResults = true
                })
            }
        }
    }
    
    // MARK: - State routing
    
    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingView
        case .loaded(let feed):
            loadedView(feed)
        case .failed(let message):
            errorView(message)
        }
    }
    
    // MARK: - Loaded
    
    private func loadedView(_ feed: HomeFeed) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                searchBar
                heroSection(feed)
                filterBar
                showMatchesButton
                // Grouped in two: `ViewBuilder` only has overloads up to 10 direct
                // children, and the split is a real one — curated rails, then the
                // rails that depend on who is signed in.
                Group {
                    huntRail("Trending Hunting Gamecasts in Texas", feed.trendingHunts)
                    gamecasterRail("Trending Gamecasters", feed.trendingGamecasters)
                    huntRail("Most popular this month", feed.popularHunts)
                    destinationRail("Gamecasts by destination", feed.destinations)
                }
                Group {
                    ForEach(feed.styleRails) { rail in
                        styleRail(rail)
                    }
                    if !feed.favorites.isEmpty {
                        huntRail("Your saved hunts", feed.favorites)
                    }
                }
                earnBanner
            }
            .padding(.vertical, 14)
        }
        .refreshable { await viewModel.refresh() }
    }
    
    // MARK: - Search bar
    
    private var searchBar: some View {
        HuntSearchPill(criteria: criteria, style: .expanded) { showingSearch = true }
            .padding(.horizontal, 16)
    }
    
    
    private var filterBar: some View {
        HuntFilterBar(
            filters: quickFilters,
            isSelected: { criteria.filters.isSelected(key: $0.queryKey, value: $0.value) },
            hasActiveFilters: !criteria.filters.isEmpty,
            onToggle: { filter in criteria.filters.toggle(key: filter.queryKey, value: filter.value, singleSelect: false) },
            onClearAll: { criteria.filters.clear() },
            onOpenAllFilters: { showingAllFilters = true }
        )
    }
    
    @ViewBuilder
    private var showMatchesButton: some View {
        if !criteria.filters.isEmpty {
            AppButton(
                title: "Show matches", type: .primary, width: .full, height: 50,
                icon: Image(systemName: "arrow.right"), iconPosition: .trailing,
                action: { showingResults = true }
            )
            .padding(.horizontal, 16)
        }
    }
    // MARK: - Hero
    
    /// The hero plus its "swap into main" alternates — the mobile reading of the
    /// portal's featured block, where `featuredHero` and the two `featuredSide`
    /// cards are one pool and any of them can be promoted into the big slot.
    @ViewBuilder private func heroSection(_ feed: HomeFeed) -> some View {
        let pool = featuredPool(feed)
        if let hero = currentHero(in: pool) {
            VStack(spacing: 12) {
                heroCard(hero)
                heroAlternates(pool.filter { $0.id != hero.id })
            }
        }
    }

    /// Hero + alternates in feed order. One pool, so promoting a side card simply
    /// changes which member is drawn large.
    private func featuredPool(_ feed: HomeFeed) -> [HuntCard] {
        guard let hero = feed.hero else { return feed.heroAlternates }
        return [hero] + feed.heroAlternates
    }

    /// The promoted card if it is still in the feed, else the feed's own hero.
    /// The id check matters after a pull-to-refresh, when the promoted hunt may
    /// no longer be featured at all.
    private func currentHero(in pool: [HuntCard]) -> HuntCard? {
        if let id = promotedHeroID, let promoted = pool.first(where: { $0.id == id }) {
            return promoted
        }
        return pool.first
    }

    @ViewBuilder private func heroAlternates(_ alternates: [HuntCard]) -> some View {
        if !alternates.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(alternates) { hunt in
                        heroAlternateCard(hunt)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func heroAlternateCard(_ hunt: HuntCard) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.28)) { promotedHeroID = hunt.id }
        } label: {
            HStack(spacing: 10) {
                RemoteImage(url: hunt.imageURL, cornerRadius: 10)
                    .frame(width: 64, height: 56)
                VStack(alignment: .leading, spacing: 3) {
                    Text(Localized("Swap into main"))
                        .typography { $0.overlineSmall }
                        .foregroundColor(theme.currentTheme.orange)
                    Text(verbatim: hunt.title)
                        .typography { $0.titleSmall }
                        .foregroundColor(theme.currentTheme.ink)
                        .lineLimit(1)
                    Text(verbatim: "\(hunt.price.formatted) · \(hunt.duration.displayLabel)")
                        .typography { $0.bodySmall }
                        .foregroundColor(theme.currentTheme.g700)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(8)
            .frame(width: 250)
            .background(theme.currentTheme.snow, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(theme.currentTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: "Swap into main: \(hunt.title)"))
    }
    
    private func heroCard(_ hunt: HuntCard) -> some View {
        RemoteImage(url: hunt.imageURL, cornerRadius: 20)
            .frame(maxWidth: .infinity)
            .frame(height: 230)
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.black.opacity(0.7), .clear],
                            startPoint: .bottom,
                            endPoint: .center
                        )
                    )
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(verbatim: "\(hunt.outfitterName) · \(hunt.city), \(hunt.state)")
                        .typography { $0.labelSmall }
                        .foregroundColor(.white.opacity(0.9))
                    Text(verbatim: hunt.title)
                        .font(theme.typography.displayLarge.font)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    HStack(spacing: 8) {
                        Text(verbatim: "From \(hunt.price.formatted)")
                            .typography { $0.titleMedium }
                            .foregroundColor(.white)
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(theme.currentTheme.hl)
                            Text(verbatim: String(format: "%.1f (%d)", hunt.rating, hunt.reviewCount))
                                .typography { $0.labelMedium }
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .padding(16)
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: hunt.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.35), radius: 3, y: 1)
                    .padding(16)
            }
            .padding(.horizontal, 16)
    }
    
    // MARK: - Rails
    
    @ViewBuilder private func huntRail(_ title: String, _ hunts: [HuntCard]) -> some View {
        if !hunts.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(title)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(hunts) { hunt in
                            HuntCardView(hunt: hunt)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    @ViewBuilder private func gamecasterRail(_ title: String, _ gamecasters: [Gamecaster]) -> some View {
        if !gamecasters.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(title)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(gamecasters) { caster in
                            GamecasterCardView(gamecaster: caster)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    @ViewBuilder private func destinationRail(_ title: String, _ destinations: [Destination]) -> some View {
        if !destinations.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(title)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(destinations) { destination in
                            DestinationCardView(destination: destination)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    /// A style rail ("By style: Family Friendly"). Same rail as the others, but the
    /// marker lands on the style name rather than on "By".
    @ViewBuilder private func styleRail(_ rail: StyleRail) -> some View {
        if !rail.items.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                markerHeader(leading: "By style:", marked: rail.label, trailing: "")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(rail.items) { hunt in
                            HuntCardView(hunt: hunt)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    /// Section header in the brand style: the first word gets a lime "marker"
    /// highlight, the rest continues in the display serif.
    private func sectionHeader(_ title: String) -> some View {
        let parts = title.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        return markerHeader(
            leading: "",
            marked: String(parts.first ?? ""),
            trailing: parts.count > 1 ? String(parts[1]) : ""
        )
    }

    /// The shared header shape. `marked` is the span that carries the lime marker;
    /// which span that is depends on the rail, which is why it is a parameter
    /// rather than always "the first word".
    private func markerHeader(leading: String, marked: String, trailing: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if !leading.isEmpty {
                Text(verbatim: leading)
                    .font(theme.typography.displayMedium.font)
                    .foregroundColor(theme.currentTheme.ink)
            }
            Text(verbatim: marked)
                .font(theme.typography.displayMedium.font)
                .foregroundColor(theme.currentTheme.ink)
                .padding(.horizontal, 8)
                .padding(.vertical, 1)
                .background(
                    theme.currentTheme.hl,
                    in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                )
            if !trailing.isEmpty {
                Text(verbatim: trailing)
                    .font(theme.typography.displayMedium.font)
                    .foregroundColor(theme.currentTheme.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Earn banner
    
    private var earnBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(verbatim: "Share your hunts. Earn with Gamecastic.")
                .typography { $0.headingMedium }
                .foregroundColor(theme.currentTheme.ink)
            Text(verbatim: "Become a Gamecaster and turn your trips into income.")
                .typography { $0.bodyMedium }
                .foregroundColor(theme.currentTheme.g700)
            AppButton(
                title: "Register as a Gamecaster",
                type: .primary,
                width: .padded(padding: 22),
                height: 48,
                action: {}
            )
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(theme.currentTheme.paper)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(theme.currentTheme.border, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - Loading skeleton
    
    private var loadingView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                searchBar
                SkeletonView(cornerRadius: 20)
                    .frame(height: 230)
                    .padding(.horizontal, 16)
                skeletonRail
                skeletonRail
            }
            .padding(.vertical, 14)
        }
        .disabled(true)
    }
    
    private var skeletonRail: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView()
                .frame(width: 200, height: 18)
                .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(0..<4, id: \.self) { _ in
                        HuntCardSkeleton()
                    }
                }
                .padding(.horizontal, 16)
            }
            .disabled(true)
        }
    }
    
    // MARK: - Error
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40, weight: .regular))
                .foregroundColor(theme.currentTheme.warn)
            Text(verbatim: message)
                .typography { $0.labelLarge }
                .foregroundColor(theme.currentTheme.ink)
                .multilineTextAlignment(.center)
            AppButton(
                title: "Try again",
                type: .primary,
                width: .fixed(width: 180),
                height: 48,
                action: { Task { await viewModel.refresh() } }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
    
    // MARK: - Category tabs
    
    /// Mirrors `CategorySelector`'s own tap handling so the drawer and the chip row
    /// can never disagree about what an unavailable category does.
    private func handleMenuCategory(_ item: CategoryItem) {
        guard item.isAvailable else {
            ToastManager.shared.show("\(item.title.resolve()) — coming soon")
            return
        }
        selectedCategory = item.id
        withAnimation(.snappy(duration: 0.28)) { showingMenu = false }
    }
    
    private var categoryItems: [CategoryItem] {
        [
            CategoryItem(id: "trending", title: "Trending", icon: Image(systemName: "flame.fill")),
            CategoryItem(id: "hunting", title: "Hunting", icon: Image(systemName: "scope")),
            CategoryItem(id: "fishing", title: "Fishing", icon: Image(systemName: "fish.fill"), isAvailable: false),
            CategoryItem(id: "lodging", title: "Lodging", icon: Image(systemName: "tent.fill"), isAvailable: false),
            CategoryItem(id: "experiences", title: "Experiences", icon: Image(systemName: "mountain.2.fill"), isAvailable: false)
        ]
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
