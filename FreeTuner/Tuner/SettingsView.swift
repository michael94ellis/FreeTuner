//
//  SettingsView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct SettingsView: View {
    @Bindable var noteConverter: NoteConverter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPad) private var isPad
    
    @State private var showingA4FrequencyPicker = false
    @State private var showingMidiReferencePicker = false
    
    // MARK: - AppStorage Properties
    @AppStorage("showPitchGraph") private var showPitchGraph: Bool = true
    @AppStorage("showSignalStrength") private var showSignalStrength: Bool = true
    @AppStorage("showReferenceLabels") private var showReferenceLabels: Bool = true
    @AppStorage("displayOptionsCollapsed") private var displayOptionsCollapsed: Bool = false
    @AppStorage("maxPitchHistorySize") private var maxPitchHistorySize: Int = 100
    @AppStorage("pitchHistoryOptionsCollapsed") private var pitchHistoryOptionsCollapsed: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        displayOptionsSection
                        pitchHistorySection
                        a4FrequencySection
                        midiReferenceSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(isPad ? .title2 : .title3)
                        .foregroundColor(.blue)
                }
                .font(isPad ? .body : .callout)
                .accessibilityLabel("Close settings")
                .accessibilityHint("Closes the settings menu and returns to the tuner")
                }
            }
        }
        .sheet(isPresented: $showingA4FrequencyPicker) {
            A4FrequencyPickerView(noteConverter: noteConverter)
        }
        .sheet(isPresented: $showingMidiReferencePicker) {
            MidiReferencePickerView(noteConverter: noteConverter)
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
    
    // MARK: - Display Options Section
    private var displayOptionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "eye")
                    .font(isPad ? .title2 : .title3)
                    .foregroundColor(.blue)
                
                Text("Display Options")
                    .font(isPad ? .largeTitle : .title2)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut) {
                        displayOptionsCollapsed.toggle()
                    }
                }) {
                                            Image(systemName: displayOptionsCollapsed ? "chevron.down" : "chevron.up")
                            .font(isPad ? .title3 : .subheadline)
                        .foregroundColor(.blue)
                        .frame(width: isPad ? 44 : 32, height: isPad ? 44 : 32)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                .accessibilityLabel("Toggle display options")
                .accessibilityValue(displayOptionsCollapsed ? "Collapsed" : "Expanded")
                .accessibilityHint("Shows or hides display option controls")
            }
            if displayOptionsCollapsed {
                displayToggles
                    .id("toggles")
                    .frame(height: 0)
                    .hidden()
            } else {
                displayToggles
                    .id("toggles")
            }
        }
        .padding(20)
        .background(sectionBackground)
        .overlay(sectionBorder)
    }
        
    private var displayToggles: some View {
        VStack(spacing: 12) {
            // Pitch Graph Toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                                    Text("Pitch Graph")
                    .font(isPad ? .title : .title3)
                    .foregroundColor(.primary)
                    
                    Text("Show real-time frequency tracking")
                        .font(isPad ? .body : .subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $showPitchGraph)
                    .labelsHidden()
                    .accessibilityLabel("Show pitch graph")
                    .accessibilityHint("Toggles visibility of the real-time pitch history graph")
            }
            .standardCardStyle()
            
            // Signal Strength Toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Signal Strength")
                        .font(isPad ? .title : .title3)
                        .foregroundColor(.primary)
                    
                    Text("Show audio level meter")
                        .font(isPad ? .body : .subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $showSignalStrength)
                    .labelsHidden()
                    .accessibilityLabel("Show signal strength")
                    .accessibilityHint("Toggles visibility of the audio input level meter")
            }
            .standardCardStyle()
            
            // Reference Labels Toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reference Labels")
                        .font(isPad ? .title : .title3)
                        .foregroundColor(.primary)
                    
                    Text("Display current frequency, cents, and octave")
                        .font(isPad ? .body : .subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $showReferenceLabels)
                    .labelsHidden()
                    .accessibilityLabel("Show reference labels")
                    .accessibilityHint("Toggles visibility of frequency, cents, and octave information")
            }
            .standardCardStyle()
        }
    }
    
    // MARK: - Pitch History Section
    private var pitchHistorySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(isPad ? .title2 : .title3)
                    .foregroundColor(.blue)
                
                Text("Pitch History")
                    .font(isPad ? .largeTitle : .title2)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut) {
                        pitchHistoryOptionsCollapsed.toggle()
                    }
                }) {
                                            Image(systemName: pitchHistoryOptionsCollapsed ? "chevron.down" : "chevron.up")
                            .font(isPad ? .title3 : .subheadline)
                        .foregroundColor(.blue)
                        .frame(width: isPad ? 44 : 32, height: isPad ? 44 : 32)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                .accessibilityLabel("Toggle pitch history options")
                .accessibilityValue(pitchHistoryOptionsCollapsed ? "Collapsed" : "Expanded")
                .accessibilityHint("Shows or hides pitch history configuration options")
            }
            
            if pitchHistoryOptionsCollapsed {
                pitchHistoryControls
                    .id("pitchHistory")
                    .frame(height: 0)
                    .hidden()
            } else {
                pitchHistoryControls
                    .id("pitchHistory")
            }
        }
        .padding(20)
        .background(sectionBackground)
        .overlay(sectionBorder)
    }
    
    private var pitchHistoryControls: some View {
        VStack(spacing: 12) {
            // Max History Size Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max History Size")
                            .font(isPad ? .title : .title3)
                            .foregroundColor(.primary)
                        
                        Text("Number of data points to keep in memory")
                            .font(isPad ? .body : .subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(maxPitchHistorySize)")
                        .font(isPad ? .title : .title3)
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    let maxValue: Double = isPad ? 1000 : 250
                    Text("50")
                        .font(isPad ? .body : .subheadline)
                        .foregroundColor(.secondary)
                    
                                    Slider(
                    value: Binding(
                        get: { Double(maxPitchHistorySize) },
                        set: { maxPitchHistorySize = Int($0) }
                    ),
                    in: 25...maxValue,
                    step: 25
                )
                .accentColor(.blue)
                .accessibilityLabel("Maximum pitch history size")
                .accessibilityValue("\(maxPitchHistorySize) data points")
                .accessibilityHint("Adjusts how many pitch measurements to keep in memory")
                    
                    Text("\(Int(maxValue))")
                        .font(isPad ? .body : .subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - A4 Frequency Section
    private var a4FrequencySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "tuningfork")
                    .font(isPad ? .title2 : .title3)
                    .foregroundColor(.blue)
                
                Text("A4 Reference Frequency")
                    .font(isPad ? .largeTitle : .title2)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Button(action: {
                showingA4FrequencyPicker = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current A4 Frequency")
                            .font(isPad ? .body : .subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(noteConverter.getA4Frequency())) Hz")
                            .font(isPad ? .title : .title3)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                }
                .standardCardStyle()
                .contentShape(Rectangle())
                .accessibilityLabel("A4 frequency settings")
                .accessibilityHint("Opens A4 reference frequency configuration")
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(sectionBackground)
        .overlay(sectionBorder)
    }
    
    // MARK: - MIDI Reference Section
    private var midiReferenceSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "pianokeys")
                    .font(isPad ? .title2 : .title3)
                    .foregroundColor(.blue)
                
                Text("MIDI Reference Note")
                    .font(isPad ? .largeTitle : .title2)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Button(action: {
                showingMidiReferencePicker = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current MIDI Reference")
                            .font(isPad ? .body : .subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(midiNoteToName(noteConverter.getA4MidiNote())) (MIDI \(noteConverter.getA4MidiNote()))")
                            .font(isPad ? .title : .title3)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                }
                .standardCardStyle()
                .contentShape(Rectangle())
                .accessibilityLabel("MIDI reference settings")
                .accessibilityHint("Opens MIDI reference note configuration")
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(sectionBackground)
        .overlay(sectionBorder)
    }
    
    // MARK: - Helper Methods
    private func midiNoteToName(_ midiNote: Int) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let noteIndex = midiNote % 12
        let octave = (midiNote / 12) - 1
        return "\(noteNames[noteIndex])\(octave)"
    }
    
    // MARK: - Section Styling
    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 8, x: 0, y: 2)
    }
    
    private var sectionBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
    }
}

#Preview {
    Group {
        SettingsView(noteConverter: NoteConverter())
            .preferredColorScheme(.light)
        
        SettingsView(noteConverter: NoteConverter())
            .preferredColorScheme(.dark)
    }
}
