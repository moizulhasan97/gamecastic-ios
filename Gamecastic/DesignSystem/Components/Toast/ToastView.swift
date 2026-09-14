//
//  ToastView.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

struct ToastView: View {
    @Environment(\.theme) private var theme
    
    let text: String
    
    var body: some View {
        Text(text)
            .typography { $0.labelMedium }
            .foregroundColor(theme.currentTheme.snow)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(theme.currentTheme.ink)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
    }
}
