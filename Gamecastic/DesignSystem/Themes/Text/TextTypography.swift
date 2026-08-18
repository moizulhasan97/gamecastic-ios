//
//  TextTypography.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

protocol Typography {
    var size: CGFloat { get }
    var weight: FontProvider { get }
    var font: Font { get }
}

extension Typography {
    var font: Font { FontProvider.getFont(name: weight.fontName, size: size) }
}

protocol TextTypography {
    var button1: Typography { get }
}
