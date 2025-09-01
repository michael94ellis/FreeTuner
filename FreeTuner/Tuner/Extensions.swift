//
//  Extensions.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/31/25.
//

import SwiftUI

var CentsTolerance: Int = 5

extension Int {
    var centsColor: Color {
        let absCents = abs(self)
        if absCents <= CentsTolerance {
            return .green
        } else if absCents <= 15 {
            return .orange
        } else {
            return .red
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
