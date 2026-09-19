//
//  CardModifier.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI
import DesignSystem

// MARK: - Card Styles

extension View {
    /// The standard small card appearance used for the pitch summary and settings rows.
    func standardCardStyle() -> some View {
        Card(config: CardConfig(style: .secondary,
                                 size: .small,
                                 background: AnyShapeStyle(Color.systemBackgroundColor))) {
            self
        }
        .elevation(.subtle)
    }

    /// The standard large card appearance used for the tuner gauge, signal meter, and pitch graph.
    func largeCardStyle() -> some View {
        Card(config: CardConfig(style: .secondary,
                                 size: .regular,
                                 background: AnyShapeStyle(Color.systemBackgroundColor))) {
            self
        }
        .elevation(.card)
    }
}
