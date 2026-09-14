//
//  CategoryChipStyleProtocol.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

protocol CategoryChipStyleProtocol {
    var backgroundColor: Color { get }
    var backgroundSelectedColor: Color { get }
    var backgroundHighlightedColor: Color { get }
    var backgroundDisabledColor: Color { get }
    
    var titleColor: Color { get }
    var titleSelectedColor: Color { get }
    var titleDisabledColor: Color { get }
    
    var borderColor: Color { get }
    var borderSelectedColor: Color { get }
    var borderDisabledColor: Color { get }
    var borderWidth: CGFloat { get }
    
    var font: Font { get }
    var cornerRadius: CornerRadius { get }
}
