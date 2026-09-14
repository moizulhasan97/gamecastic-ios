//
//  GamecasticApp.swift
//  Gamecastic
//
//  Created by Moiz Ul Hasan on 25/07/2026.
//

import SwiftUI

@main
struct GamecasticApp: App {
    
    init() {
#if DEBUG
        // Fails loudly (in the log) if a bundled face isn't registered under the
        // PostScript name FontProvider expects — otherwise the app just quietly
        // renders in the system font. See FontProvider.
        FontProvider.auditBundledFonts()
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(AuthManager.shared)
                .task { await AuthManager.shared.restoreSession() }
        }
    }
}
