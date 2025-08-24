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
            Text("FreeTuner")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Pitch Display
            VStack(spacing: 8) {
                if let pitch = currentPitch, pitch > 0 {
                    Text("\(Int(pitch)) Hz")
                        .font(.system(size: 36, weight: .medium, design: .monospaced))
                        .foregroundColor(.green)
                    
                    let noteString = noteConverter.frequencyToNoteString(pitch)
                    Text(noteString)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(noteConverter.isInTune(pitch) ? .green : .orange)
                    
                    let direction = noteConverter.getTuningDirection(pitch)
                    Text(direction)
                        .font(.caption)
                        .foregroundColor(direction == "In Tune" ? .green : .secondary)
                } else {
                    Text("No pitch detected")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Pitch Graph
            VStack(spacing: 8) {
                Text("Frequency Spectrum")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                PitchGraphView(spectrum: currentSpectrum)
                
                FrequencyLabelsView(spectrum: currentSpectrum)
            }
            .padding(.horizontal)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button(action: {
                if isListening {
                    pitchManager.stop()
                    isListening = false
                    currentSpectrum = []
                } else {
                    startListening()
                }
            }) {
                Text(isListening ? "Stop Listening" : "Start Listening")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isListening ? Color.red : Color.blue)
                    .cornerRadius(10)
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
