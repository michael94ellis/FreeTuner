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
    @AppStorage("maxPitchHistorySize") private var maxPitchHistorySize: Int = 100
    
    var body: some View {
        ScrollView {
            VStack(spacing: isPad ? 24 : 8) {
                
                listeningHeader
                
                let detectedNote = currentPitch.flatMap({
                    noteConverter.frequencyToNote($0)
                })
                
                if showReferenceLabels {
                    pitchSummaryView(detectedNote: detectedNote)
                        .standardCardStyle()
                }
                
                let tunerView = TunerCircleView(detectedNote: detectedNote,
                                                isListening: $isListening)
                    .padding(.horizontal, isPad ? 32 : 20)
                    .frame(maxHeight: isPad ? .infinity : 500)
                    .frame(minHeight: isPad ? 500 : 300)
                
                let onlyShowTuner = !showReferenceLabels && !showPitchGraph && !showSignalStrength
                if onlyShowTuner {
                    tunerView
                } else {
                    tunerView
                        .largeCardStyle()
                }
                
                if showSignalStrength {
                    VStack(spacing: 0) {
                        DecibelMeterView(decibels: currentDecibels, isListening: isListening)
                    }
                    .largeCardStyle()
                }
                
                if showPitchGraph {
                    VStack(spacing: 0) {
                        PitchGraphView(pitchData: pitchData, isListening: isListening, maxDataPoints: maxPitchHistorySize)
                    }
                    .largeCardStyle()
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
    
    var listeningHeader: some View {
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
    }
    
    @ViewBuilder
    func pitchSummaryView(detectedNote: Note?) -> some View {
        HStack(spacing: isPad ? 24 : 16) {
            // Current Frequency Display
            VStack(spacing: isPad ? 8 : 6) {
                Text("Frequency")
                    .captionFont(isPad: isPad)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(String(format: "%4d Hz", Int(currentPitch ?? 0)))
                    .frequencyFont(isPad: isPad)
                    .foregroundColor(.primary)
                    .monospacedDigit()
            }
            
            // Cents Display
            VStack(spacing: isPad ? 6 : 4) {
                Text("Cents")
                    .labelFont(isPad: isPad)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(detectedNote?.cents.formatCents ?? "0")
                    .centsFont(isPad: isPad)
                    .foregroundColor(detectedNote?.cents.centsColor)
                    .fontWeight(.bold)
                    .scaleEffect(detectedNote?.cents.centsColor == .green ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: detectedNote?.cents.centsColor)
            }
            
            // Octave Display
            VStack(spacing: isPad ? 6 : 4) {
                Text("Octave")
                    .labelFont(isPad: isPad)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text("\(detectedNote?.octave ?? 0)")
                    .octaveFont(isPad: isPad)
                    .foregroundColor(.primary)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
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
            .warningCardStyle()
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
                        if pitchData.count > maxPitchHistorySize {
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
