//
//  TunerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct TunerView: View {
    let pitchManager: AudioInputManager
    @State var noteConverter: NoteConverter
    
    @Binding var isListening: Bool
    @Binding var errorMessage: String?
    @Binding var currentPitch: Float?
    @Binding var currentSpectrum: [(frequency: Float, magnitude: Float)]
    @Binding var currentDecibels: (rms: CGFloat, peak: CGFloat)
    
    @State private var showingTemperamentPicker = false
    @State private var showingA4FrequencyPicker = false
    @State var pitchDetectionTask: Task<Void, Never>?
    @State private var pitchData: [PitchDataPoint] = []
    
    // Device-specific sizing
    @Environment(\.isPad) private var isPad
    
    var body: some View {
        VStack(spacing: 24) {
            
            headerButtons
                .padding(.top, isPad ? 16 : 8)
            
            // Add tap hint when not listening
            Text(isListening ? "Listening…" : "🎙 Tap anywhere to start")
                .font(.system(size: isPad ? 24 : 15, weight: .semibold, design: .rounded))
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
            
            // Decibel Meter and Pitch Graph - stack vertically on smaller screens
            VStack(spacing: 16) {
                DecibelMeterView(decibels: currentDecibels, isListening: isListening)
                
                // Pitch Graph
                PitchGraphView(pitchData: pitchData, isListening: isListening)
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
        .sheet(isPresented: $showingTemperamentPicker) {
            TemperamentPickerView(noteConverter: noteConverter)
        }
        .sheet(isPresented: $showingA4FrequencyPicker) {
            A4FrequencyPickerView(noteConverter: noteConverter)
        }
    }
    
    var headerButtons: some View {
        // Settings Row with modern card design
        HStack(spacing: 16) {
            // Temperament Selector
            Button(action: {
                showingTemperamentPicker = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Temperament")
                            .font(.system(size: isPad ? 18 : 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(noteConverter.currentTemperament.rawValue)
                            .font(.system(size: isPad ? 24 : 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: isPad ? 18 : 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, isPad ? 20 : 12)
                .padding(.vertical, isPad ? 16 : 8)
                .frame(maxWidth: .infinity)
                .frame(height: isPad ? 110 : 80)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // A4 Frequency Selector
            Button(action: {
                showingA4FrequencyPicker = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("A4 Reference")
                            .font(.system(size: isPad ? 18 : 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(noteConverter.getA4Frequency())) Hz")
                            .font(.system(size: isPad ? 24 : 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: isPad ? 18 : 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, isPad ? 20 : 12)
                .padding(.vertical, isPad ? 16 : 8)
                .frame(maxWidth: .infinity)
                .frame(height: isPad ? 110 : 80)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    var errorMessageView: some View {
        // Error message with better styling
        if let error = errorMessage {
                    HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: isPad ? 22 : 16, weight: .medium))
            
            Text(error)
                .font(.system(size: isPad ? 20 : 14, weight: .medium))
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
