//
//  HuntPrimitives.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 31/08/2026.
//

import Foundation

// App-wide hunt value types.
//
// These started life in `Features/Home/Domain/Models` and were reused by
// HuntSearch, which made one feature depend on another. They live in Core so
// every feature depends on Core instead — and so a future Hunt Detail or Booking
// slice has somewhere obvious to reuse them from.
//
// Normalisation (parsing wire strings into these) stays in each feature's mapper:
// the mapper is the single seam between a specific endpoint's quirks and the
// domain, and those quirks differ per endpoint.

/// A monetary amount. `currencyCode` defaults to USD until the backend confirms.
nonisolated struct Money: Hashable, Sendable {
    let amount: Double
    let currencyCode: String

    // TODO(backend): Hunts are USD-only today, so we pin the US locale to render
    // "$1,850" (matching the web). Revisit if/when pricing becomes multi-currency
    // or the app needs to localise the currency symbol to the user's region.
    var formatted: String {
        amount.formatted(
            .currency(code: currencyCode)
                .precision(.fractionLength(0))
                .locale(Locale(identifier: "en_US"))
        )
    }
}

/// Time-of-day a hunt runs. Unknown server values are preserved via `.other`
/// so a new backend value never crashes the app.
nonisolated enum HuntSchedule: Hashable, Sendable {
    case morning
    case afternoon
    case fullDay
    case other(String)

    init(raw: String) {
        switch raw.lowercased() {
        case "morning":   self = .morning
        case "afternoon": self = .afternoon
        case "fullday":   self = .fullDay
        default:          self = .other(raw)
        }
    }
}

/// Normalised hunt duration.
///
/// `/hunts` and `/hunts/{id}` send structured `duration` + `durationUnit`, while
/// `/home` still sends a pre-formatted display string ("3 Days"). Both are parsed
/// into this shape by their own mapper, so the UI never has to care which
/// endpoint the value came from.
nonisolated struct HuntDuration: Hashable, Sendable {
    enum Unit: Sendable {
        case day
        case hour
        case unknown
    }

    let value: Int
    let unit: Unit
    let displayLabel: String
}
