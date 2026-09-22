//
//  A4FrequencyPickerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI
import DesignSystem

struct A4FrequencyPickerView: View {
    @Bindable var noteConverter: NoteConverter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPad) private var isPad
    @State private var selectedA4Frequency: Float
    @StateObject private var pitchPlayer = PitchPlayer()
    @State private var debounceTimer: Timer?
    @State private var isEditingFrequency = false
    @State private var manualFrequencyText = ""
    
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
        // Use the actual A4 pitch (not the raw stored reference), since the
        // stored reference may currently be anchored to a different MIDI note
        // via the MIDI Reference Note picker.
        self._selectedA4Frequency = State(initialValue: noteConverter.getActualA4Frequency())
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
                Color.systemBackgroundColor,
                Color.backgroundElevated.opacity(0.3)
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
                .font(isPad ? .body : .subheadline)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: 20) {
                if isEditingFrequency {
                    HStack {
                        TextField("Enter frequency", text: $manualFrequencyText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(isPad ? .title : .title3)
                            .multilineTextAlignment(.center)
                            .onSubmit {
                                if let frequency = Float(manualFrequencyText) {
                                    selectedA4Frequency = frequency
                                }
                                isEditingFrequency = false
                            }
                        
                        Button("Done") {
                            if let frequency = Float(manualFrequencyText) {
                                selectedA4Frequency = frequency
                            }
                            isEditingFrequency = false
                        }
                        .font(isPad ? .title : .subheadline)
                        .foregroundColor(.accent)
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                } else {
                                    Button(action: {
                    manualFrequencyText = "\(Int(selectedA4Frequency))"
                    isEditingFrequency = true
                }) {
                    Text("\(Int(selectedA4Frequency)) Hz")
                        .font(isPad ? .system(size: 48) : .title)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.text)
                        .shadow(color: Color.shadow.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Current A4 frequency")
                .accessibilityValue("\(Int(selectedA4Frequency)) Hertz")
                .accessibilityHint("Tap to edit the A4 reference frequency")
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }
                
                Button(action: {
                    if pitchPlayer.isCurrentlyPlaying {
                        pitchPlayer.stop()
                    } else {
                        pitchPlayer.play(frequency: selectedA4Frequency)
                    }
                }) {
                    Image(systemName: pitchPlayer.isCurrentlyPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(isPad ? .system(size: 48) : .title)
                        .foregroundColor(pitchPlayer.isCurrentlyPlaying ? .destructive : .accent)
                        .shadow(color: Color.shadow.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(pitchPlayer.isCurrentlyPlaying ? "Stop reference tone" : "Play reference tone")
                .accessibilityValue("\(Int(selectedA4Frequency)) Hertz")
                .accessibilityHint("Plays or stops a reference tone at the current A4 frequency")
            }
            .animation(.easeInOut(duration: 0.3), value: isEditingFrequency)
            
            waveformSelector
        }
        .largeCardStyle()
    }

    private var waveformSelector: some View {
        VStack(spacing: 8) {
            Text("Waveform")
                .font(isPad ? .body : .subheadline)
                .foregroundColor(.textSecondary)

            SegmentedPicker(
                options: WaveformType.allCases.map { ($0.rawValue, $0) },
                selection: Binding(
                    get: { pitchPlayer.selectedWaveform },
                    set: { newWaveform in
                        pitchPlayer.selectedWaveform = newWaveform
                        guard pitchPlayer.isCurrentlyPlaying else { return }
                        pitchPlayer.stop()
                        pitchPlayer.play(frequency: selectedA4Frequency)
                    }
                )
            )
        }
    }

    // MARK: - Custom Frequency Slider
    private var customFrequencySlider: some View {
        VStack(spacing: 16) {
            Text("Custom Frequency")
                .font(isPad ? .title : .title3)
                .frame(maxWidth: .infinity, alignment: .leading)

            sliderControls
        }
        .largeCardStyle()
    }

    private var sliderControls: some View {
        HStack {
            Text("1 Hz")
                .font(isPad ? .body : .subheadline)
                .foregroundColor(.textSecondary)

            Slider(
                value: $selectedA4Frequency,
                in: 1...990,
                step: 1
            )
            .tint(.accent)
            .accessibilityLabel("A4 frequency slider")
            .accessibilityValue("\(Int(selectedA4Frequency)) Hertz")
            .accessibilityHint("Adjust the A4 reference frequency from 1 to 990 Hertz")
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

            Text("990 Hz")
                .font(isPad ? .body : .subheadline)
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - Common Standards Section
    private var commonStandardsSection: some View {
        VStack(spacing: 16) {
            Text("Common Standards")
                .font(isPad ? .title : .title3)
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
        .largeCardStyle()
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
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
        .font(isPad ? .body : .callout)
        .accessibilityLabel("Cancel")
        .accessibilityHint("Discards changes and returns to settings")
    }
    
    private var applyButton: some View {
        Button("Apply") {
            withAnimation(.easeInOut(duration: 0.2)) {
                // This screen always defines true A4, so applying a value here
                // re-anchors the reference to MIDI note 69. Otherwise, if the
                // reference had been shifted to a different note via the MIDI
                // Reference Note picker, the value chosen here would silently
                // become that other note's pitch instead of A4's.
                noteConverter.setA4Frequency(selectedA4Frequency)
                noteConverter.setA4MidiNote(69)
                dismiss()
            }
        }
        .font(isPad ? .title : .title3)
        .foregroundColor(.accent)
        .accessibilityLabel("Apply")
        .accessibilityHint("Saves the A4 frequency setting and returns to settings")
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
