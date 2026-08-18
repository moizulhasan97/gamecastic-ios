//
//  DefaultTextTypography.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import Foundation

struct DefaultTextTypography: TextTypography {
    var button1: Typography { Button1() }
}

// button/uppercase — 14pt, Inter ExtraBold
struct Button1: Typography {
    var size: CGFloat { 14.0 }
    var weight: FontProvider { .inter(weight: .extraBold) }
}
