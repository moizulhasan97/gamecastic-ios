//
//  CategorySelector.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

// MARK: - Model

struct CategoryItem: Identifiable, Equatable {
    let id: String
    let title: Localized
    let icon: Image
    let isAvailable: Bool
    
    init(id: String, title: Localized, icon: Image, isAvailable: Bool = true) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isAvailable = isAvailable
    }
    
    static func == (lhs: CategoryItem, rhs: CategoryItem) -> Bool { lhs.id == rhs.id }
}

// MARK: - Selector

struct CategorySelector: View {
    private let items: [CategoryItem]
    @Binding private var selection: String
    private let horizontalPadding: CGFloat
    private let onUnavailableTap: ((CategoryItem) -> Void)?
    
    /// - Parameters:
    ///   - items: Ordered list of categories to render.
    ///   - selection: Binding to the selected item's `id`. The component never mutates this for unavailable items.
    ///   - onUnavailableTap: Called instead of selection when a disabled item is tapped.
    ///     Defaults to showing `ToastManager.shared` with a "coming soon" message — override for custom UX (e.g. a waitlist sheet).
    init(
        items: [CategoryItem],
        selection: Binding<String>,
        horizontalPadding: CGFloat = 16,
        onUnavailableTap: ((CategoryItem) -> Void)? = nil
    ) {
        self.items = items
        self._selection = selection
        self.horizontalPadding = horizontalPadding
        self.onUnavailableTap = onUnavailableTap
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items) { item in
                    CategoryChip(item: item, isSelected: item.id == selection) {
                        handleTap(on: item)
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 6)
        }
    }
    
    private func handleTap(on item: CategoryItem) {
        guard item.isAvailable else {
            if let onUnavailableTap {
                onUnavailableTap(item)
            } else {
                ToastManager.shared.show("\(item.title.resolve()) — coming soon")
            }
            return
        }
        selection = item.id
    }
}

// MARK: - Chip

private struct CategoryChip: View {
    @Environment(\.theme) private var theme
    
    let item: CategoryItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                item.icon
                    .renderingMode(.template)
                    .imageScale(.medium)
                Text(item.title)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .frame(height: 40)
            .contentShape(Capsule())
        }
        .buttonStyle(
            CategoryChipButtonStyle(
                style: theme.categoryChipStyle.style(for: .standard),
                isSelected: isSelected,
                isAvailable: item.isAvailable
            )
        )
        .accessibilityLabel(Text(item.title))
        .accessibilityHint(item.isAvailable ? "" : "Coming soon")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - ButtonStyle

private struct CategoryChipButtonStyle: ButtonStyle {
    let style: any CategoryChipStyleProtocol
    let isSelected: Bool
    let isAvailable: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed && isAvailable
        
        let backgroundColor = !isAvailable ? style.backgroundDisabledColor
        : isSelected ? style.backgroundSelectedColor
        : isPressed ? style.backgroundHighlightedColor
        : style.backgroundColor
        
        let contentColor = !isAvailable ? style.titleDisabledColor
        : isSelected ? style.titleSelectedColor
        : style.titleColor
        
        let borderColor = !isAvailable ? style.borderDisabledColor
        : isSelected ? style.borderSelectedColor
        : style.borderColor
        
        return configuration.label
            .font(style.font)
            .foregroundColor(contentColor)
            .background(backgroundColor)
            .overlay(Capsule().stroke(borderColor, lineWidth: style.borderWidth))
            .clipShape(Capsule())
            .opacity(isAvailable ? 1.0 : 0.7)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isPressed)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selection = "trending"
        
        private let items: [CategoryItem] = [
            CategoryItem(id: "trending", title: "Trending", icon: Image(systemName: "flame.fill")),
            CategoryItem(id: "hunting", title: "Hunting", icon: Image(systemName: "scope")),
            CategoryItem(id: "fishing", title: "Fishing", icon: Image(systemName: "fish.fill"), isAvailable: false),
            CategoryItem(id: "lodging", title: "Lodging", icon: Image(systemName: "tent.fill"), isAvailable: false),
            CategoryItem(id: "experiences", title: "Experiences", icon: Image(systemName: "mountain.2.fill"), isAvailable: false)
        ]
        
        var body: some View {
            CategorySelector(items: items, selection: $selection)
        }
    }
    
    return PreviewWrapper()
        .padding(.vertical)
        .background(Color(.systemGray6))
        .toastPresenter()
}
