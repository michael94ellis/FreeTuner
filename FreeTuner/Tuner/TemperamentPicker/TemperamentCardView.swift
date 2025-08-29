//
//  TemperamentCardView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct TemperamentCardView: View {
    @Environment(\.isPad) private var isPad
    let temperament: Temperament
    let isSelected: Bool
    let temperamentConverter: TemperamentConverter
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                headerSection
                
                if temperament != .equal {
                    deviationSection
                }
            }
            .padding(20)
            .background(cardBackground)
            .overlay(cardBorder)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(temperament.rawValue)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(temperament.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            checkmarkIcon
        }
    }
    
    private var checkmarkIcon: some View {
        Group {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 24, weight: .medium))
                    .scaleEffect(1.1)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 24, weight: .medium))
                    .scaleEffect(1.1)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                    .hidden()
            }
        }
    }
    
    // MARK: - Deviation Section
    private var deviationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Deviations from Equal Temperament")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ForEach(["C", "D", "E", "F", "G", "A", "B"], id: \.self) { note in
                    DeviationNoteView(
                        note: note,
                        deviation: temperamentConverter.getCentsDeviation(note, temperament: temperament)
                    )
                }
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - Card Styling
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 8, x: 0, y: 2)
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1),
                lineWidth: isSelected ? 2 : 1
            )
    }
}

#Preview {
    VStack(spacing: 16) {
        TemperamentCardView(
            temperament: .equal,
            isSelected: true,
            temperamentConverter: TemperamentConverter(),
            onSelect: {}
        )
        
        TemperamentCardView(
            temperament: .pythagorean,
            isSelected: false,
            temperamentConverter: TemperamentConverter(),
            onSelect: {}
        )
    }
    .padding()
    .background(Color(.systemGray6))
}
