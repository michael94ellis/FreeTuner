//
//  A4FrequencyPickerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct A4FrequencyPickerView: View {
    @Bindable var noteConverter: NoteConverter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPad) private var isPad
    @State private var selectedA4Frequency: Float
    
    // Common A4 frequencies used throughout history
    let commonA4Frequencies: [(name: String, frequency: Float?)] = [
        ("Modern Standard (A440)", 440.0),
        ("Baroque (A415)", 415.0),
        ("Classical (A430)", 430.0),
        ("Verdi (A432)", 432.0),
        ("Historical (A409)", 409.0),
        ("Early Music (A392)", 392.0),
    ]
    
    init(noteConverter: NoteConverter) {
        self.noteConverter = noteConverter
        self._selectedA4Frequency = State(initialValue: noteConverter.getA4Frequency())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        currentFrequencyDisplay
                        customFrequencySlider
                        commonStandardsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("A4 Frequency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemGray6).opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Current Frequency Display
    private var currentFrequencyDisplay: some View {
        VStack(spacing: 12) {
            Text("Current A4 Frequency")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("\(Int(selectedA4Frequency)) Hz")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 2, x: 0, y: 1)
        }
        .padding(24)
        .background(currentFrequencyBackground)
        .overlay(currentFrequencyBorder)
    }
    
    private var currentFrequencyBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 8, x: 0, y: 2)
    }
    
    private var currentFrequencyBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
    }
    
    // MARK: - Custom Frequency Slider
    private var customFrequencySlider: some View {
        VStack(spacing: 16) {
            Text("Custom Frequency")
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            sliderControls
            
            frequencyDisplay
        }
        .padding(20)
        .background(customSliderBackground)
        .overlay(customSliderBorder)
    }
    
    private var sliderControls: some View {
        HStack {
            Text("400 Hz")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Slider(
                value: $selectedA4Frequency,
                in: 400...480,
                step: 1
            )
            .accentColor(.blue)
            
            Text("480 Hz")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    private var frequencyDisplay: some View {
        Text("\(Int(selectedA4Frequency)) Hz")
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(.blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(frequencyDisplayBackground)
    }
    
    private var frequencyDisplayBackground: some View {
        Capsule()
            .fill(Color.blue.opacity(0.1))
    }
    
    private var customSliderBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var customSliderBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
    }
    
    // MARK: - Common Standards Section
    private var commonStandardsSection: some View {
        VStack(spacing: 16) {
            Text("Common Standards")
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(commonA4Frequencies, id: \.name) { standard in
                    FrequencyStandardButton(
                        standard: standard,
                        isSelected: selectedA4Frequency == (standard.frequency ?? selectedA4Frequency),
                        onSelect: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if let frequency = standard.frequency {
                                    selectedA4Frequency = frequency
                                }
                            }
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(commonStandardsBackground)
        .overlay(commonStandardsBorder)
    }
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }
    
    private var commonStandardsBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 8, x: 0, y: 2)
    }
    
    private var commonStandardsBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            cancelButton
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            applyButton
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
        .font(.system(size: 16, weight: .medium))
    }
    
    private var applyButton: some View {
        Button("Apply") {
            withAnimation(.easeInOut(duration: 0.2)) {
                noteConverter.setA4Frequency(selectedA4Frequency)
                dismiss()
            }
        }
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(.blue)
    }
}

// MARK: - Frequency Standard Button
struct FrequencyStandardButton: View {
    let standard: (name: String, frequency: Float?)
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Text(standard.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                frequencyText
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(buttonBackground)
            .overlay(buttonBorder)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var frequencyText: some View {
        Group {
            if let frequency = standard.frequency {
                Text("\(Int(frequency)) Hz")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            } else {
                Text("Custom")
                    .font(.system(size: 18, weight: .semibold))
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

#Preview {
    Group {
        A4FrequencyPickerView(noteConverter: NoteConverter())
            .preferredColorScheme(.light)
        
        A4FrequencyPickerView(noteConverter: NoteConverter())
            .preferredColorScheme(.dark)
    }
}
