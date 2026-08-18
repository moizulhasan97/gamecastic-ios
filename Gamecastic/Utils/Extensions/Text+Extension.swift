//
//  Text+Extension.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 26/07/2026.
//

import SwiftUI

extension Text {
    init(
        _ localized: Localized,
        _ args: CVarArg...
    ) {
        self.init(localized.resolve(args))
    }
}
