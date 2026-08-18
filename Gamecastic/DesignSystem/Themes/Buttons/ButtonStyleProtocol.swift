//
//  ButtonStyleProtocol.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import SwiftUI

protocol ButtonStyleProtocol {
    var backgroundColor: Color { get }
    var backgroundDisabledColor: Color { get }
    var backgroundHighlightedColor: Color { get }
    
    var titleColor: Color { get }
    var titleDisabledColor: Color { get }
    var titleHighlightedColor: Color { get }
    
    var borderColor: Color { get }
    var borderDisabledColor: Color { get }
    var borderHighlightedColor: Color { get }
    var borderWidth: CGFloat { get }
    
    var cornerRadius: CornerRadius { get }
    var font: Font { get }
    
    var textCase: Text.Case? { get }
    var tracking: CGFloat { get }
}

extension ButtonStyleProtocol {
    var textCase: Text.Case? { .uppercase }
    var tracking: CGFloat { 0.6 }
}
