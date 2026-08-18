//
//  FontProvider.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//


import SwiftUI

enum FontProvider {
    enum Weight {
        case light      // 300
        case regular    // 400
        case medium     // 500
        case semiBold   // 600
        case bold       // 700
        case extraBold  // 800
    }
    
    case inter(weight: Weight)
    
    var fontName: String {
        switch self {
        case .inter(let weight):
            switch weight {
            case .light:     return "Inter-Light"
            case .regular:   return "Inter-Regular"
            case .medium:    return "Inter-Medium"
            case .semiBold:  return "Inter-SemiBold"
            case .bold:      return "Inter-Bold"
            case .extraBold: return "Inter-ExtraBold"
            }
        }
    }
    
    static func getFont(name: String, size: CGFloat) -> Font {
        Font.custom(name, size: size)
    }
}
