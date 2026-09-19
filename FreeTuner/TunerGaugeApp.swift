//
//  TunerGaugeApp.swift
//  TunerGauge
//
//  Created by Michael Ellis on 8/22/25.
//

import SwiftUI
import DesignSystem

@main
struct TunerGaugeApp: App {
    init() {
        DesignToken.current.colors = ColorToken(
            primary: .hex("1B4FE0"),
            secondary: .hex("D62828"),
            tertiary: .hex("1E8E4E"),
            quaternary: .white,
            success: .hex("1E8E4E"),
            warning: .hex("B3261E"),
            destructive: .hex("D62828"),
            text: .hex("101114"),
            textSecondary: .hex("6B7075"),
            fillSubtle: .hex("101114", opacity: 0.06),
            fill: .hex("101114", opacity: 0.12),
            systemBackgroundColor: .hex("F6F7F9"),
            backgroundElevated: .hex("E6E8EC"),
            shadow: .black.withOpacity(0.18)
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
