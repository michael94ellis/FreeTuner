//
//  MidiStandardButton.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct MidiStandardButton: View {
    let standard: (name: String, note: Int, description: String)
    let isSelected: Bool
    let onSelect: () -> Void
    
    @Environment(\.isPad) private var isPad
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Text(standard.name)
                    .font(isPad ? .title : .title3)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                
                Text(standard.description)
                    .font(isPad ? .body : .subheadline)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemBackground))
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Group {
        MidiStandardButton(
            standard: ("A4 (Standard)", 69, "Modern standard reference"),
            isSelected: true,
            onSelect: {}
        )
        .preferredColorScheme(.light)
        
        MidiStandardButton(
            standard: ("C4 (Middle C)", 60, "Middle C reference"),
            isSelected: false,
            onSelect: {}
        )
        .preferredColorScheme(.dark)
    }
    .padding()
}
