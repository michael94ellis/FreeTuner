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
    
    var body: some View {
        VStack(spacing: 20) {
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
