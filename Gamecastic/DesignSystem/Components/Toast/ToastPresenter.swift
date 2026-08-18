//
//  ToastPresenter.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

struct ToastPresenter: ViewModifier {
    @ObservedObject private var toastManager = ToastManager.shared

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let toast = toastManager.currentToast {
                    ToastView(text: toast.text)
                        .padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .id(toast.id)
                        .zIndex(1)
                }
            }
    }
}

extension View {
    /// Attach once near the app root so any screen can call `ToastManager.shared.show(_:)`.
    func toastPresenter() -> some View {
        modifier(ToastPresenter())
    }
}
