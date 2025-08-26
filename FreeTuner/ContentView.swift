//
//  ContentView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/22/25.
//

import SwiftUI

struct ContentView: View {
    let pitchManager = AudioInputManager()
    @StateObject private var noteConverter = NoteConverter()
    @StateObject private var metronome = Metronome()
    
    @State private var isListening = false
    @State private var errorMessage: String?
    @State private var currentPitch: Float?
    @State private var currentSpectrum: [(frequency: Float, magnitude: Float)] = []
    
    var body: some View {
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
            
            TabView {
                TunerView(
                    pitchManager: pitchManager,
                    noteConverter: noteConverter,
                    isListening: $isListening,
                    errorMessage: $errorMessage,
                    currentPitch: $currentPitch,
                    currentSpectrum: $currentSpectrum
                )
                .tabItem {
                    Image(systemName: "tuningfork")
                    Text("Tuner")
                }
                .tag(0)
                
                // Metronome Tab
                MetronomeView(metronome: metronome)
                    .tabItem {
                        Image(systemName: "timer")
                        Text("Metronome")
                    }
                    .tag(1)
                
                // Tuning fork can play different notes in different octaves
//                TuningForkView()
//                .tabItem {
//                    Image(systemName: "music.note.list")
//                    Text("Notes")
//                }
//                .tag(2)
            }
            .accentColor(.blue)
        }
    }
}

#Preview {
    ContentView()
}
