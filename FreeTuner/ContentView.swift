//
//  ContentView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/22/25.
//

import SwiftUI

struct ContentView: View {
    
    
    enum ViewState {
        case tuner
        case metronome
        case both
    }
    let pitchManager = AudioInputManager()
    let noteConverter = NoteConverter()
    @StateObject private var metronome = Metronome()
    
    @State private var isListening = false
    @State private var errorMessage: String?
    @State private var currentPitch: Float?
    @State private var currentSpectrum: [(frequency: Float, magnitude: Float)] = []
    @State private var viewState: ViewState = .tuner

    var body: some View {
        // Tuner Tab
        VStack {
            
            Picker("Mode", selection: $viewState, content: {
                Label(title: {
                    Text("Tuner")
                }, icon: {
                    Image(systemName: "tuningfork")
                })
                .tag(ViewState.tuner)
                Label(title: {
                    Text("Metronome")
                }, icon: {
                    Image(systemName: "timer")
                })
                .tag(ViewState.metronome)
                Label(title: {
                    Text("Both")
                }, icon: {
                    Image(systemName: "music.note.list")
                })
                .tag(ViewState.both)
            })
            .pickerStyle(.segmented)
            
            switch viewState {
            case .tuner:
                TunerView(
                    pitchManager: pitchManager,
                    noteConverter: noteConverter,
                    isListening: $isListening,
                    errorMessage: $errorMessage,
                    currentPitch: $currentPitch,
                    currentSpectrum: $currentSpectrum
                )
                .id("tuner")
            case .metronome:
                MetronomeView(metronome: metronome)
                    .id("metronome")
            case .both:
                ViewThatFits {
                    HStack {
                        TunerView(
                            pitchManager: pitchManager,
                            noteConverter: noteConverter,
                            isListening: $isListening,
                            errorMessage: $errorMessage,
                            currentPitch: $currentPitch,
                            currentSpectrum: $currentSpectrum
                        )
                        .id("tuner")
                        MetronomeView(metronome: metronome)
                            .id("metronome")
                    }
                    VStack {
                        TunerView(
                            pitchManager: pitchManager,
                            noteConverter: noteConverter,
                            isListening: $isListening,
                            errorMessage: $errorMessage,
                            currentPitch: $currentPitch,
                            currentSpectrum: $currentSpectrum
                        )
                        .id("tuner")
                        MetronomeView(metronome: metronome)
                            .id("metronome")
                    }
                    
                }
            }
            
    }
    }
}

#Preview {
    ContentView()
}
