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
    @StateObject private var pitchPlayer = PitchPlayer()
    @State private var debounceTimer: Timer?
    
    // Common A4 frequencies used throughout history
    let commonA4Frequencies: [(name: String, frequency: Float?)] = [
        ("Modern Standard (A440)", 440.0),
        ("Baroque (A415)", 415.0),
        ("Classical (A430)", 430.0),
        ("Verdi (A432)", 432.0),
        ("Historical (A409)", 409.0),
        ("Early Music (A392)", 392.0),
        ("Low A4 (A400)", 400.0),
        ("High A4 (A480)", 480.0),
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
            .onDisappear {
                pitchPlayer.stop()
                debounceTimer?.invalidate()
                debounceTimer = nil
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
        VStack(spacing: 16) {
            Text("Current A4 Frequency")
                .captionFont(isPad: isPad)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                Text("\(Int(selectedA4Frequency)) Hz")
                    .titleFont(isPad: isPad)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primary)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 2, x: 0, y: 1)
                
                Button(action: {
                    if pitchPlayer.isCurrentlyPlaying {
                        pitchPlayer.stop()
                    } else {
                        pitchPlayer.play(frequency: selectedA4Frequency)
                    }
                }) {
                    Image(systemName: pitchPlayer.isCurrentlyPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundColor(pitchPlayer.isCurrentlyPlaying ? .red : .blue)
                        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            waveformSelector
        }
        .padding(20)
        .background(currentFrequencyBackground)
        .overlay(currentFrequencyBorder)
    }
    
    private var waveformSelector: some View {
            VStack(spacing: 8) {
                Text("Waveform")
                    .captionFont(isPad: isPad)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    ForEach(WaveformType.allCases, id: \.self) { waveform in
                        Button(action: {
                            pitchPlayer.selectedWaveform = waveform
                        }) {
                            Text(waveform.rawValue)
                                .smallFont(isPad: isPad)
                                .foregroundColor(pitchPlayer.selectedWaveform == waveform ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(pitchPlayer.selectedWaveform == waveform ? Color.blue : Color(.systemGray5))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onChange(of: pitchPlayer.selectedWaveform, {
                            guard pitchPlayer.isCurrentlyPlaying else {
                                return
                            }
                            pitchPlayer.stop()
                            pitchPlayer.play(frequency: selectedA4Frequency)
                        })
                    }
                }
            }
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
                .subheadingFont(isPad: isPad)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            sliderControls
        }
        .padding(20)
        .background(customSliderBackground)
        .overlay(customSliderBorder)
    }
    
    private var sliderControls: some View {
        HStack {
            Text("350 Hz")
                .captionFont(isPad: isPad)
                .foregroundColor(.secondary)
            
            Slider(
                value: $selectedA4Frequency,
                in: 350...500,
                step: 1
            )
            .accentColor(.blue)
            .onChange(of: selectedA4Frequency) {
                guard pitchPlayer.isCurrentlyPlaying else {
                    return
                }
                // Cancel any existing timer
                debounceTimer?.invalidate()
                
                // Create a new timer with 0.3 second delay
                debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                    pitchPlayer.stop()
                    pitchPlayer.play(frequency: selectedA4Frequency)
                }
            }
            
            Text("500 Hz")
                .captionFont(isPad: isPad)
                .foregroundColor(.secondary)
        }
    }
    
    private var frequencyDisplay: some View {
        HStack(spacing: 16) {
            Text("\(Int(selectedA4Frequency)) Hz")
                .headingFont(isPad: isPad)
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(frequencyDisplayBackground)
        }
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
                .subheadingFont(isPad: isPad)
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
        .bodyFont(isPad: isPad)
    }
    
    private var applyButton: some View {
        Button("Apply") {
            withAnimation(.easeInOut(duration: 0.2)) {
                noteConverter.setA4Frequency(selectedA4Frequency)
                dismiss()
            }
        }
        .subheadingFont(isPad: isPad)
        .foregroundColor(.blue)
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
