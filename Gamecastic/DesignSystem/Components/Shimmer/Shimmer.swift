//
//  Shimmer.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 18/08/2026.
//

import SwiftUI

/// Airbnb-style shimmer: a soft highlight sweeps across a placeholder while
/// content loads. Apply to any redacted / skeleton shape via `.shimmering()`.
///
/// Intentionally dependency-free (no SPM package) — it's a thin, reusable
/// `ViewModifier` so the whole app shares one shimmer look.
struct ShimmerEffect: ViewModifier {

    /// When `false` the modifier is a no-op (lets call sites bind it to a
    /// loading flag without branching).
    var isActive: Bool = true

    private let bandWidthRatio: CGFloat = 0.35
    private let duration: Double = 1.15

    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay {
                    GeometryReader { proxy in
                        let width = proxy.size.width
                        let band = max(width * bandWidthRatio, 60)
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.0),
                                .white.opacity(0.6),
                                .white.opacity(0.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: band)
                        // Travel from just off the leading edge to just past the trailing edge.
                        .offset(x: phase * (width + band) - band)
                        .blendMode(.plusLighter)
                    }
                    .allowsHitTesting(false)
                }
                .clipped()
                .onAppear {
                    phase = 0
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    /// Sweeps a shimmer highlight across the view while `active` is true.
    func shimmering(_ active: Bool = true) -> some View {
        modifier(ShimmerEffect(isActive: active))
    }
}

// MARK: - Skeleton building block

/// A neutral, rounded placeholder block that shimmers — the atom of every
/// skeleton screen. Compose several of these to mirror a real card's layout.
struct SkeletonView: View {
    @Environment(\.theme) private var theme

    var cornerRadius: CGFloat = 12

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(theme.currentTheme.g200)
            .shimmering()
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        SkeletonView(cornerRadius: 16)
            .frame(width: 230, height: 150)
        SkeletonView()
            .frame(width: 180, height: 14)
        SkeletonView()
            .frame(width: 120, height: 14)
    }
    .padding()
}
