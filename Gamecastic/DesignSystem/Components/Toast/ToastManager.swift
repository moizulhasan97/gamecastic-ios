//
//  ToastManager.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI
import Combine

struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
}

final class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published private(set) var currentToast: ToastMessage?
    
    private var dismissWorkItem: DispatchWorkItem?
    
    private init() {}
    
    func show(_ text: String, duration: TimeInterval = 2.5) {
        dismissWorkItem?.cancel()
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            currentToast = ToastMessage(text: text)
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            withAnimation(.easeOut(duration: 0.25)) {
                self?.currentToast = nil
            }
        }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }
}
