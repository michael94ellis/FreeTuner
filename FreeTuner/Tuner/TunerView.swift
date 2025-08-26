//
//  TunerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct TunerView: View {
    let pitchManager: AudioInputManager
    @ObservedObject var  noteConverter: NoteConverter
    
    @Binding var isListening: Bool
    @Binding var errorMessage: String?
    @Binding var currentPitch: Float?
    @Binding var currentSpectrum: [(frequency: Float, magnitude: Float)]
    
    @State private var showingTemperamentPicker = false
    @State private var showingA4FrequencyPicker = false
    @State var pitchDetectionTask: Task<Void, Never>?
    
    var body: some View {
        VStack(spacing: 24) {
            // Settings Row with modern card design
            HStack(spacing: 16) {
                // Temperament Selector
                Button(action: {
                    showingTemperamentPicker = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Temperament")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(noteConverter.getTemperament().rawValue)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(noteConverter.getA4Frequency())) Hz")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
            
            // Add tap hint when not listening
            Text(isListening ? "Listening…" : "🎙 Tap anywhere to start")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(isListening ? .white : .blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
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
            .padding(.horizontal, 20)
            
            // Error message with better styling
            if let error = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(error)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
            }
            

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
    
    private func setupPitchDetection() {
        pitchDetectionTask = Task {
            guard let pitchStream = pitchManager.stream else { return }
            
            for await (pitch, spectrum) in pitchStream {
                await MainActor.run {
                    self.currentPitch = pitch > 0 ? pitch : nil
                    self.currentSpectrum = spectrum
                }
            }
        }
    }
    
    private func startListening() {
        errorMessage = nil
        currentPitch = nil
        currentSpectrum = []
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
    TunerView(
        pitchManager: AudioInputManager(),
        noteConverter: NoteConverter(),
        isListening: .constant(false),
        errorMessage: .constant(nil),
        currentPitch: .constant(nil),
        currentSpectrum: .constant([])
    )
}
