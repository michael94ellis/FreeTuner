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
    @StateObject private var noteConverter = NoteConverter()
    @StateObject private var metronome = Metronome()
    
    @State private var isListening = false
    @State private var errorMessage: String?
    @State private var currentPitch: Float?
    @State private var currentSpectrum: [(frequency: Float, magnitude: Float)] = []
    @State private var viewState: ViewState = .tuner

    var body: some View {
        GeometryReader { geo in
            
            let tunerView: some View =
                TunerView(
                    pitchManager: pitchManager,
                    noteConverter: noteConverter,
                    isListening: $isListening,
                    errorMessage: $errorMessage,
                    currentPitch: $currentPitch,
                    currentSpectrum: $currentSpectrum
                )
                .id("tuner")
                .frame(width: geo.size.width, height: geo.size.height)
            
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
                    tunerView
                case .metronome:
                    MetronomeView(metronome: metronome)
                        .id("metronome")
                case .both:
                    ViewThatFits {
                        HStack {
                            tunerView
                            MetronomeView(metronome: metronome)
                                .id("metronome")
                        }
                        ScrollView {
                            VStack {
                                tunerView
                                MetronomeView(metronome: metronome)
                                    .id("metronome")
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
