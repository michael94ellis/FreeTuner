//
//  Extensions.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/31/25.
//

import SwiftUI
import DesignSystem

// `DesignSystem` re-declares `Color.primary`/`Color.secondary`, which collides
// with SwiftUI's own statics of the same name (ambiguous use of 'primary'/'secondary').
// These give every other file an unambiguous way to reach the design system's
// brand accent colors instead of reaching for the bare, colliding names.
extension Color {
    static var accent: Color { DesignToken.current.colors.primary.color }
    static var accentSecondary: Color { DesignToken.current.colors.secondary.color }
}

var CentsTolerance: Int = 5

extension Int {
    var centsColor: Color {
        let absCents = abs(self)
        if absCents <= CentsTolerance {
            return .success
        } else if absCents <= 15 {
            return .warning
        } else {
            return .destructive
        }
    }
    
    var formatCents: String {
        if self <= CentsTolerance && self >= -CentsTolerance {
            return "✓"
        } else if self > 0 {
            return "+\(self)¢"
        } else {
            return "\(self)¢"
        }
    }
}
