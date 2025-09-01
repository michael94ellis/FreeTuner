//
//  FrequencyStandardButton.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/30/25.
//

import SwiftUI

struct FrequencyStandardButton: View {
    @Environment(\.isPad) private var isPad: Bool
    let standard: (name: String, frequency: Float?)
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text(standard.name)
                .font(isPad ? .caption : .caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            frequencyText
            
            Button(action: onSelect) {
                Text("Select")
                    .font(isPad ? .caption : .caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.blue : Color.gray)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(buttonBackground)
        .overlay(buttonBorder)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var frequencyText: some View {
        Group {
            if let frequency = standard.frequency {
                Text("\(Int(frequency)) Hz")
                    .font(isPad ? .title2 : .title3)
                    .foregroundColor(.primary)
            } else {
                Text("Custom")
                    .font(isPad ? .title2 : .title3)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                isSelected ? 
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    private var buttonBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(
                isSelected ? Color.blue.opacity(0.3) : Color.clear,
                lineWidth: 2
            )
    }
}
