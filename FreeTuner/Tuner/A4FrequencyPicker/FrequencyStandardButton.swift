//
//  FrequencyStandardButton.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/30/25.
//

import SwiftUI
import DesignSystem

struct FrequencyStandardButton: View {
    @Environment(\.isPad) private var isPad: Bool
    let standard: (name: String, frequency: Float?)
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(standard.name)
                .font(isPad ? .body : .caption2)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            frequencyText

            Button("Select", action: onSelect)
                .buttonStyle(isSelected ? .primarySmall : .secondarySmall)
                .accessibilityLabel("Select \(standard.name)")
                .accessibilityValue(isSelected ? "Selected" : "Not selected")
                .accessibilityHint("Sets the A4 frequency to \(standard.name)")
        }
        .frame(maxWidth: .infinity)
        .standardCardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.cardSmall)
                .stroke(isSelected ? Color.accent.opacity(0.4) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private var frequencyText: some View {
        Group {
            if let frequency = standard.frequency {
                Text("\(Int(frequency)) Hz")
                    .font(isPad ? .title : .title3)
                    .foregroundColor(.text)
            } else {
                Text("Custom")
                    .font(isPad ? .title : .title3)
                    .foregroundColor(.accent)
            }
        }
    }
}
