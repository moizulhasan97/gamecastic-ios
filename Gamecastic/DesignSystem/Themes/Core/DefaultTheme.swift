//
//  DefaultTheme.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import SwiftUI

struct DefaultTheme: AppTheme {
    var orange: Color { getColor("orange") }
    var orangeDeep: Color { getColor("orange-deep") }
    var hl: Color { getColor("hl") }
    var hlDeep: Color { getColor("hl-deep") }
    var snow: Color { getColor("snow") }
    var paper: Color { getColor("paper") }
    var paperDeep: Color { getColor("paper-deep") }
    var ink: Color { getColor("ink") }
    var charcoal: Color { getColor("charcoal") }
    var leather: Color { getColor("leather") }
    var g100: Color { getColor("g-100") }
    var g200: Color { getColor("g-200") }
    var g300: Color { getColor("g-300") }
    var g500: Color { getColor("g-500") }
    var g700: Color { getColor("g-700") }
    var border: Color { getColor("border") }
    var borderMid: Color { getColor("border-mid") }
    var signal: Color { getColor("signal") }
    var warn: Color { getColor("warn") }
    var info: Color { getColor("info") }
    var risk: Color { getColor("risk") }
    var purple: Color { getColor("purple") }
    
    // MARK: - Images
    
    var logo: Image? { .init("ic_gamecastic_black") }
}
