//
//  AppButton.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

enum IconPosition {
    case leading, trailing
}

struct AppButton: View {
    @Environment(\.theme) private var theme
    
    private let title: Localized
    private let type: DefaultButtonStyle.ButtonType
    private let width: CustomWidth
    private let height: CGFloat
    private let isDisabled: Bool
    private let icon: Image?
    private let iconPosition: IconPosition
    private let action: () -> Void
    
    init(
        title: Localized,
        type: DefaultButtonStyle.ButtonType,
        width: CustomWidth = .full,
        height: CGFloat = 52.0,
        isDisabled: Bool = false,
        icon: Image? = nil,
        iconPosition: IconPosition = .leading,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.type = type
        self.width = width
        self.height = height
        self.isDisabled = isDisabled
        self.icon = icon
        self.iconPosition = iconPosition
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if iconPosition == .leading { icon }
                Text(title)
                    .lineLimit(1)
                if iconPosition == .trailing { icon }
            }
            .frame(height: height)
            .frame(minHeight: height)
            .contentShape(Rectangle())
        }
        .buttonStyle(DefaultButtonStyle(theme: theme, width: width, type: type, isDisabled: isDisabled))
        .disabled(isDisabled)
    }
}

// MARK: - ButtonStyle
struct DefaultButtonStyle: ButtonStyle {
    enum ButtonType {
        case primary
        case overlay
        case outlineOnDark
    }
    
    let theme: AppThemeManager
    let width: CustomWidth
    let type: ButtonType
    let isDisabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        let style = theme.buttonStyle.style(for: type)
        let isPressed = configuration.isPressed && !isDisabled
        
        let backgroundColor = isDisabled ? style.backgroundDisabledColor
        : isPressed ? style.backgroundHighlightedColor : style.backgroundColor
        let titleColor = isDisabled ? style.titleDisabledColor
        : isPressed ? style.titleHighlightedColor : style.titleColor
        let borderColor = isDisabled ? style.borderDisabledColor
        : isPressed ? style.borderHighlightedColor : style.borderColor
        
        return configuration.label
            .font(style.font)
            .textCase(style.textCase)
            .tracking(style.tracking)
            .modifier(WidthModifier(width: width))
            .background(backgroundColor)
            .foregroundColor(titleColor)
            .overlay(
                Group {
                    switch style.cornerRadius {
                    case .fixed(let radius):
                        RoundedRectangle(cornerRadius: radius).stroke(borderColor, lineWidth: style.borderWidth)
                    case .capsule:
                        Capsule().stroke(borderColor, lineWidth: style.borderWidth)
                    }
                }
            )
            .modifier(CornerRadiusModifier(cornerRadius: style.cornerRadius))
            .opacity(isDisabled ? 0.6 : 1.0)
    }
}

private struct WidthModifier: ViewModifier {
    let width: CustomWidth
    func body(content: Content) -> some View {
        switch width {
        case .full: content.frame(maxWidth: .infinity)
        case .fixed(let width): content.frame(width: CGFloat(width))
        case .padded(let padding): content.padding(.horizontal, padding)
        }
    }
}

private struct CornerRadiusModifier: ViewModifier {
    let cornerRadius: CornerRadius
    func body(content: Content) -> some View {
        switch cornerRadius {
        case .fixed(let radius): content.cornerRadius(radius)
        case .capsule: content.clipShape(Capsule())
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        // TODO: replace Image("icon-arrow-right") once the asset is imported in Xcode
        AppButton(title: "Request to Book", type: .primary, icon: Image("icon-arrow-right"), action: {})
        HStack(spacing: 8) {
            AppButton(title: "Share", type: .overlay, width: .full, height: 44, icon: Image("icon-share"), action: {})
            AppButton(title: "Save", type: .overlay, width: .full, height: 44, icon: Image("icon-heart"), action: {})
        }
        .padding().background(Color.black)
        AppButton(title: "See how it works", type: .outlineOnDark, action: {})
            .padding().background(Color.black)
    }
    .padding()
}
