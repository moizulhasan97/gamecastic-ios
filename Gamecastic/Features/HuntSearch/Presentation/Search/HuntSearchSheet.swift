//
//  HuntSearchSheet.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 25/08/2026.
//

import SwiftUI

/// The search-bar editor. WHERE (region) + SEARCH (free text) are live today;
/// WHEN + WHO are shown as disabled "coming soon" rows so the layout is final —
/// they activate the moment `/hunts` gains date + party params (see
/// `HuntSearchCriteria`). A sticky "Show N matches" footer applies the criteria.
///
/// Static copy → `Text(Localized("…"))`; dynamic values → `Text(verbatim:)`.
struct HuntSearchSheet: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: HuntSearchSheetViewModel
    private let onApply: (HuntSearchCriteria) -> Void
    
    init(viewModel: HuntSearchSheetViewModel, onApply: @escaping (HuntSearchCriteria) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onApply = onApply
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(theme.currentTheme.border)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    whereSection
                    searchSection
                    comingSoonSection(
                        title: "When",
                        icon: "calendar",
                        placeholder: "Any dates"
                    )
                    comingSoonSection(
                        title: "Who · party",
                        icon: "person.2",
                        placeholder: "Any party size"
                    )
                }
                .padding(20)
            }
            footer
        }
        .background(theme.currentTheme.paper.ignoresSafeArea())
        .task { viewModel.onAppear() }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(Localized("Find your hunt"))
                    .typography { $0.overlineLarge }
                    .foregroundColor(theme.currentTheme.g500)
                Text(Localized("Search"))
                    .typography { $0.displayMedium }
                    .foregroundColor(theme.currentTheme.ink)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(theme.currentTheme.ink)
                    .frame(width: 36, height: 36)
                    .background(theme.currentTheme.snow, in: Circle())
                    .overlay(Circle().stroke(theme.currentTheme.border, lineWidth: 1))
            }
            .accessibilityLabel(Text(Localized("Close")))
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }
    
    // MARK: - Where
    
    private var whereSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(icon: "mappin.and.ellipse", "Where")
            FlowLayout(horizontalSpacing: 8, verticalSpacing: 10) {
                ForEach(viewModel.regions) { region in
                    RegionChip(
                        label: region.label,
                        isSelected: viewModel.isSelected(region),
                        action: { viewModel.selectRegion(region) }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Search
    
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(icon: "magnifyingglass", "Search")
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.currentTheme.g500)
                TextField(
                    "",
                    text: $viewModel.criteria.searchText,
                    prompt: Text(Localized("Try whitetail, Texas, lodging…"))
                        .foregroundColor(theme.currentTheme.g500)
                )
                .typography { $0.labelLarge }
                .foregroundColor(theme.currentTheme.ink)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onChange(of: viewModel.criteria.searchText) { _, _ in
                    viewModel.searchTextChanged()
                }
                if !viewModel.criteria.searchText.isEmpty {
                    Button {
                        viewModel.criteria.searchText = ""
                        viewModel.searchTextChanged()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(theme.currentTheme.g500)
                    }
                    .accessibilityLabel(Text(Localized("Clear search")))
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(theme.currentTheme.snow, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(theme.currentTheme.border, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Coming soon (When / Who)
    
    private func comingSoonSection(title: String, icon: String, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                sectionTitle(icon: icon, LocalizedStringKey(title))
                Text(Localized("Coming soon"))
                    .typography { $0.overlineMedium }
                    .foregroundColor(theme.currentTheme.g500)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(theme.currentTheme.g100, in: Capsule())
            }
            HStack {
                Text(verbatim: placeholder)
                    .typography { $0.labelLarge }
                    .foregroundColor(theme.currentTheme.g500)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.currentTheme.g500)
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(theme.currentTheme.paper, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(theme.currentTheme.border, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(0.7)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        VStack(spacing: 0) {
            Divider().overlay(theme.currentTheme.border)
            HStack(spacing: 12) {
                if viewModel.canReset {
                    Button { viewModel.reset() } label: {
                        Text(Localized("Reset"))
                            .typography { $0.titleMedium }
                            .foregroundColor(theme.currentTheme.ink)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 4)
                    }
                }
                Spacer(minLength: 0)
                applyButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(theme.currentTheme.snow)
        }
    }
    
    private var applyButton: some View {
        Button {
            onApply(viewModel.criteria)
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Text(verbatim: applyTitle)
                    .typography { $0.button1 }
                    .tracking(0.4)
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(theme.currentTheme.snow)
            .padding(.horizontal, 22)
            .frame(height: 50)
            .background(theme.currentTheme.orange, in: Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: viewModel.matchCount)
    }
    
    private var applyTitle: String {
        guard let count = viewModel.matchCount else { return "Show matches" }
        return count == 1 ? "Show 1 match" : "Show \(count) matches"
    }
    
    // MARK: - Helpers
    
    private func sectionTitle(icon: String, _ key: LocalizedStringKey) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(theme.currentTheme.orange)
            Text(key)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(theme.currentTheme.ink)
        }
    }
}

// MARK: - Region chip

private struct RegionChip: View {
    @Environment(\.theme) private var theme
    
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(verbatim: label)
                .typography { $0.titleMedium }
                .foregroundColor(isSelected ? theme.currentTheme.snow : theme.currentTheme.ink)
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background(isSelected ? theme.currentTheme.orange : theme.currentTheme.snow, in: Capsule())
                .overlay(Capsule().stroke(isSelected ? Color.clear : theme.currentTheme.border, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
        .accessibilityLabel(Text(verbatim: label))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
