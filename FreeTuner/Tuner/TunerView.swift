//
//  TunerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct TunerView: View {
    let pitchManager: AudioInputManager
    @Bindable var noteConverter: NoteConverter
    @Binding var isListening: Bool
    @Binding var errorMessage: String?
    @Binding var currentPitch: Float?
    @Binding var currentSpectrum: [FrequencyMagnitude]
    @Binding var currentDecibels: (rms: CGFloat, peak: CGFloat)
    
    @Environment(\.isPad) private var isPad
    
    @State private var pitchData: [PitchDataPoint] = []
    @State private var pitchDetectionTask: Task<Void, Never>?
    
    @AppStorage("showPitchGraph") private var showPitchGraph: Bool = true
    @AppStorage("showSignalStrength") private var showSignalStrength: Bool = true
    @AppStorage("showReferenceLabels") private var showReferenceLabels: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Add tap hint when not listening
                Text(isListening ? "Listening…" : "🎙 Tap anywhere to start")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(isListening ? .white : .blue)
                    .padding(.horizontal, isPad ? 32 : 16)
                    .padding(.vertical, isPad ? 16 : 8)
                    .background(
                        Capsule()
                            .fill(isListening ? Color.blue : Color.blue.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.blue.opacity(isListening ? 0.5 : 0.3), lineWidth: 1)
                            )
                    )
                    .animation(.easeInOut(duration: 0.2), value: isListening)
                    .accessibilityLabel(isListening ? "Voice recognition active" : "Tap to start listening")
                
                
                TunerCircleView(detectedNote: currentPitch.flatMap {
                    noteConverter.frequencyToNote($0)
                },
                                isListening: $isListening)
                .padding(.horizontal, isPad ? 32 : 20)
                .frame(maxHeight: isPad ? .infinity : 500)
                .frame(minHeight: isPad ? 500 : 300)
                
                // Settings Summary (only show if reference labels are enabled)
                if showReferenceLabels {
                    settingsSummaryView
                }
                
                // Decibel Meter and Pitch Graph - stack vertically on smaller screens
                VStack(spacing: 16) {
                    // Signal Strength Meter (only show if enabled)
                    if showSignalStrength {
                        DecibelMeterView(decibels: currentDecibels, isListening: isListening)
                    }
                    
                    // Pitch Graph (only show if enabled)
                    if showPitchGraph {
                        PitchGraphView(pitchData: pitchData, isListening: isListening)
                    }
                }
                
                errorMessageView
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isListening {
                        pitchManager.stop()
                        isListening = false
                        currentSpectrum = []
                        pitchDetectionTask?.cancel()
                        pitchDetectionTask = nil
                    } else {
                        startListening()
                    }
                }
            }
        }
    }
    
    // MARK: - Settings Summary View
    @ViewBuilder
    var settingsSummaryView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                // A4 Frequency
                VStack(spacing: 4) {
                    Text("A4 Frequency")
                        .captionFont(isPad: isPad)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(noteConverter.getA4Frequency())) Hz")
                        .subheadingFont(isPad: isPad)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                
                // MIDI Reference
                VStack(spacing: 4) {
                    Text("MIDI Reference")
                        .captionFont(isPad: isPad)
                        .foregroundColor(.secondary)
                    
                    Text("\(midiNoteToName(noteConverter.getA4MidiNote()))")
                        .subheadingFont(isPad: isPad)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, isPad ? 32 : 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Helper Methods
    private func midiNoteToName(_ midiNote: Int) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let noteIndex = midiNote % 12
        let octave = (midiNote / 12) - 1
        return "\(noteNames[noteIndex])\(octave)"
    }
    
    @ViewBuilder
    var errorMessageView: some View {
        // Error message with better styling
        if let error = errorMessage {
                    HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.subheadline.weight(.medium))
            
            Text(error)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, isPad ? 32 : 20)
        .padding(.vertical, isPad ? 20 : 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private func setupPitchDetection() {
        pitchDetectionTask = Task {
            guard let pitchStream = pitchManager.stream else { return }
            
            for await (pitch, spectrum, decibels) in pitchStream {
                await MainActor.run {
                    self.currentPitch = pitch > 0 ? pitch : nil
                    self.currentSpectrum = spectrum
                    self.currentDecibels = (rms: CGFloat(decibels.rms), peak: CGFloat(decibels.peak))
                    
                    // Update pitch data for graph
                    if pitch > 0 {
                        let dataPoint = PitchDataPoint(
                            timestamp: Date(),
                            frequency: pitch
                        )
                        
                        // Add new data point and maintain max data points
                        pitchData.append(dataPoint)
                        if pitchData.count > 100 {
                            pitchData.removeFirst()
                        }
                    }
                    

                }
            }
        }
    }
    
    private func startListening() {
        errorMessage = nil
        currentPitch = nil
        currentSpectrum = []
        currentDecibels = (-60.0, -60.0) // Reset decibel level
        pitchData = [] // Clear pitch data when starting
        setupPitchDetection()
        do {
            try pitchManager.start()
            isListening = true
        } catch {
            errorMessage = "Failed to start audio: \(error.localizedDescription)"
            assertionFailure("Audio engine failed to start: \(error)")
        }
    }
}

#Preview {
    Group {
        TunerView(
            pitchManager: AudioInputManager(),
            noteConverter: NoteConverter(),
            isListening: .constant(false),
            errorMessage: .constant(nil),
            currentPitch: .constant(nil),
            currentSpectrum: .constant([]),
            currentDecibels: .constant((-60.0, -60.0))
        )
        .preferredColorScheme(.light)
        
        TunerView(
            pitchManager: AudioInputManager(),
            noteConverter: NoteConverter(),
            isListening: .constant(true),
            errorMessage: .constant("Test error message"),
            currentPitch: .constant(440.0),
            currentSpectrum: .constant([]),
            currentDecibels: .constant((-25, -25))
        )
        .preferredColorScheme(.dark)
    }
}


