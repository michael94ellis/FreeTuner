//
//  TunerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct TunerView: View {
    let pitchManager: AudioInputManager
    let noteConverter: NoteConverter
    
    @Binding var isListening: Bool
    @Binding var errorMessage: String?
    @Binding var currentPitch: Float?
    @Binding var currentSpectrum: [(frequency: Float, magnitude: Float)]
    
    @State private var showingTemperamentPicker = false
    @State private var showingA4FrequencyPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Settings Row
            HStack(spacing: 12) {
                // Temperament Selector
                Button(action: {
                    showingTemperamentPicker = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Temperament")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(noteConverter.getTemperament().rawValue)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // A4 Frequency Selector
                Button(action: {
                    showingA4FrequencyPicker = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("A4 Reference")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(noteConverter.getA4Frequency())) Hz")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            GeometryReader { geo in
                // Circular Note Display
                TunerCircleView(
                    detectedNote: currentPitch.flatMap { noteConverter.frequencyToNote($0) },
                    isListening: isListening
                )
                .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            // Control Button
            Button(action: {
                if isListening {
                    pitchManager.stop()
                    isListening = false
                    currentSpectrum = []
                } else {
                    startListening()
                }
            }) {
                HStack {
                    Image(systemName: isListening ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title2)
                    Text(isListening ? "Stop Tuning" : "Start Tuning")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isListening ? Color.red : Color.blue)
                .cornerRadius(15)
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding()
        .onAppear {
            setupPitchDetection()
        }
        .sheet(isPresented: $showingTemperamentPicker) {
            TemperamentPickerView(noteConverter: noteConverter)
        }
        .sheet(isPresented: $showingA4FrequencyPicker) {
            A4FrequencyPickerView(noteConverter: noteConverter)
        }
    }
    
    private func setupPitchDetection() {
        pitchManager.onPitchDetected = { pitch, spectrum in
            DispatchQueue.main.async {
                self.currentPitch = pitch > 0 ? pitch : nil
                self.currentSpectrum = spectrum
            }
        }
    }
    
    private func startListening() {
        errorMessage = nil
        currentPitch = nil
        currentSpectrum = []
        
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
