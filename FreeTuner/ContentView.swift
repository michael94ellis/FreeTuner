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
            
            TunerView(
                pitchManager: pitchManager,
                noteConverter: noteConverter,
                isListening: $isListening,
                errorMessage: $errorMessage,
                currentPitch: $currentPitch,
                currentSpectrum: $currentSpectrum
            )
        }
    }
}

#Preview {
    Group {
        ContentView()
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        
        ContentView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
}
