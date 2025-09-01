//
//  ContentView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/22/25.
//

import SwiftUI

struct ContentView: View {
    let pitchManager = AudioInputManager()
    @State private var noteConverter = NoteConverter()
    
    @State private var isListening = false
    @State private var errorMessage: String?
    @State private var currentPitch: Float?
    @State private var currentSpectrum: [FrequencyMagnitude] = []
    @State private var currentDecibels: (rms: CGFloat, peak: CGFloat) = (rms: -60.0, peak: -60.0)
    @State private var showingSettings = false
    
    @Environment(\.isPad) private var isPad
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                TunerView(
                    pitchManager: pitchManager,
                    noteConverter: noteConverter,
                    isListening: $isListening,
                    errorMessage: $errorMessage,
                    currentPitch: $currentPitch,
                    currentSpectrum: $currentSpectrum,
                    currentDecibels: $currentDecibels
                )
            }
            .navigationTitle("FreeTuner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "slider.vertical.3")
                            .font(isPad ? .title2 : .title3)
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityHint("Opens the settings menu to configure tuner options")
                }
            }
        }
        .fullScreenCover(isPresented: $showingSettings) {
            SettingsView(noteConverter: noteConverter)
        }
    }
}
