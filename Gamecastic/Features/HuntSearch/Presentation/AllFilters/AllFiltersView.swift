//
//  AllFiltersView.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 19/08/2026.
//

import SwiftUI

/// The "All filters" sheet: every facet section with multi-select option chips,
/// a live match count, and Apply / Clear all.
///
/// Static UI copy uses `Text(Localized("…"))`; server-provided facet labels use
/// `Text(verbatim:)`.
struct AllFiltersView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: AllFiltersViewModel
    
    /// Called with the finalised selection when the user taps Apply.
    private let onApply: (HuntFilterSelection) -> Void
    
    init(viewModel: AllFiltersViewModel, onApply: @escaping (HuntFilterSelection) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onApply = onApply
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(theme.currentTheme.border)
            content
            footer
        }
        .background(theme.currentTheme.paper.ignoresSafeArea())
        .task { await viewModel.load() }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(Localized("Refine your hunt"))
                    .typography { $0.overlineLarge }
                    .foregroundColor(theme.currentTheme.g500)
                Text(Localized("All filters"))
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
    
    // MARK: - Content
    
    @ViewBuilder private var content: some View {
        switch viewModel.facetsState {
        case .loading:
            loadingView
        case .loaded(let sections):
            sectionsList(sections)
        case .failed(let message):
            errorView(message)
        }
    }
    
    private func sectionsList(_ sections: [FacetSection]) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(sections) { section in
                    facetSection(section)
                }
            }
            .padding(20)
        }
    }
    
    private func facetSection(_ section: FacetSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(verbatim: section.label)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(theme.currentTheme.ink)
            
            FlowLayout(horizontalSpacing: 8, verticalSpacing: 10) {
                ForEach(section.options) { option in
                    FacetOptionChip(
                        label: option.label,
                        count: option.count,
                        isSelected: viewModel.isSelected(sectionID: section.id, optionID: option.id),
                        action: {
                            viewModel.toggle(
                                sectionID: section.id,
                                optionID: option.id,
                                singleSelect: section.isSingleSelect
                            )
                        }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Loading / error
    
    private var loadingView: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(0..<4, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 12) {
                    SkeletonView().frame(width: 110, height: 16)
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { _ in
                            SkeletonView(cornerRadius: 19).frame(width: 96, height: 38)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 40))
                .foregroundColor(theme.currentTheme.g500)
            Text(verbatim: message)
                .typography { $0.labelLarge }
                .foregroundColor(theme.currentTheme.g700)
                .multilineTextAlignment(.center)
            AppButton(title: "Try again", type: .primary, width: .padded(padding: 26), height: 46) {
                Task { await viewModel.load() }
            }
            .fixedSize()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        VStack(spacing: 0) {
            Divider().overlay(theme.currentTheme.border)
            HStack(spacing: 12) {
                if viewModel.hasSelection {
                    Button { viewModel.clearAll() } label: {
                        Text(Localized("Clear all"))
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
            onApply(viewModel.selection)
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
    
    /// "Show 12 matches" / "Show matches" (while counting) / "Show 1 match".
    private var applyTitle: String {
        guard let count = viewModel.matchCount else { return "Show matches" }
        return count == 1 ? "Show 1 match" : "Show \(count) matches"
    }
}

// MARK: - Facet option chip

private struct FacetOptionChip: View {
    @Environment(\.theme) private var theme
    
    let label: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(verbatim: label)
                    .typography { $0.titleMedium }
                Text(verbatim: "\(count)")
                    .typography { $0.labelSmall }
                    .foregroundColor(countColor)
            }
            .foregroundColor(isSelected ? theme.currentTheme.snow : theme.currentTheme.ink)
            .padding(.horizontal, 14)
            .frame(height: 38)
            .background(isSelected ? theme.currentTheme.orange : theme.currentTheme.snow, in: Capsule())
            .overlay(Capsule().stroke(isSelected ? Color.clear : theme.currentTheme.border, lineWidth: 1))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
        .accessibilityLabel(Text(verbatim: "\(label), \(count) available"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    private var countColor: Color {
        isSelected ? theme.currentTheme.snow.opacity(0.8) : theme.currentTheme.g500
    }
}
