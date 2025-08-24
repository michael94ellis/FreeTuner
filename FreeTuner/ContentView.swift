//
//  ContentView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/22/25.
//

import SwiftUI

struct ContentView: View {
    
    let pitchManager = PitchTapManager()
    let noteConverter = NoteConverter()
    
    @State private var isListening = false
    @State private var errorMessage: String?
    @State private var currentPitch: Float?
    @State private var currentSpectrum: [(frequency: Float, magnitude: Float)] = []

    var body: some View {
        VStack(spacing: 20) {
            
            // Circular Note Display
            CircularNoteDisplay(
                detectedNote: currentPitch.flatMap { noteConverter.frequencyToNote($0) },
                isListening: isListening
            )
            .frame(maxWidth: 350, maxHeight: 350)
            
            // Spectrum Graph (optional - can be toggled)
            VStack(spacing: 8) {
                Text("Frequency Spectrum")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                PitchGraphView(spectrum: currentSpectrum)
                    .frame(height: 120)
                
                FrequencyLabelsView(spectrum: currentSpectrum)
            }
            .padding(.horizontal)
            
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
        }
        .padding()
        .onAppear {
            setupPitchDetection()
        }
    }
    
    private func setupPitchDetection() {
        pitchManager.onPitchDetected = { pitch, spectrum in
            DispatchQueue.main.async {
                self.currentPitch = pitch > 0 ? pitch : nil
                self.currentSpectrum = spectrum
                
                if pitch > 0 {
                    print("🎯 Detected pitch: \(pitch) Hz")
                    if let note = self.noteConverter.frequencyToNote(pitch) {
                        print("🎵 Musical note: \(note.name)\(note.octave) (\(note.cents)¢)")
                    }
                } else {
                    print("📊 Spectrum updated - no dominant pitch detected")
                }
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
            print("Audio engine failed to start: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
