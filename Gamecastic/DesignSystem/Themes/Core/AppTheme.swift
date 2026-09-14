//
//  AppTheme.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

protocol AppTheme {
    var orange: Color { get }
    var orangeDeep: Color { get }
    var hl: Color { get }
    var hlDeep: Color { get }
    var snow: Color { get }
    var paper: Color { get }
    var paperDeep: Color { get }
    var ink: Color { get }
    var charcoal: Color { get }
    var leather: Color { get }
    var g100: Color { get }
    var g200: Color { get }
    var g300: Color { get }
    var g500: Color { get }
    var g700: Color { get }
    var border: Color { get }
    var borderMid: Color { get }
    var signal: Color { get }
    var warn: Color { get }
    var info: Color { get }
    var risk: Color { get }
    var purple: Color { get }
    
    // MARK: - Images
    
    /// Primary Gamecastic wordmark, shown in the top bar.
    var logo: Image? { get }
}

extension AppTheme {
    func getColor(_ id: String) -> Color { Color(id) }
}
