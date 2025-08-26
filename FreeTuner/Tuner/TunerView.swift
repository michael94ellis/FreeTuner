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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
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
            
            TunerCircleView(
                detectedNote: currentPitch.flatMap { noteConverter.frequencyToNote($0) },
                isListening: isListening
            )
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
            
            // Enhanced Control Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isListening {
                        pitchManager.stop()
                        isListening = false
                        currentSpectrum = []
                    } else {
                        startListening()
                    }
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: isListening ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                    
                    Text(isListening ? "Stop Tuning" : "Start Tuning")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: isListening ?
                                                   [Color.red, Color.red.opacity(0.8)] :
                                                    [Color.blue, Color.purple]
                                                  ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: isListening ? .red.opacity(0.3) : .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                .scaleEffect(isListening ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isListening)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            Spacer()
        }
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
