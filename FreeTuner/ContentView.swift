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
    @StateObject private var metronome = LoopingMetronome()
    
    @State private var isListening = false
    @State private var errorMessage: String?
    @State private var currentPitch: Float?
    @State private var currentSpectrum: [(frequency: Float, magnitude: Float)] = []
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad: Use TabView
                iPadLayout
            } else {
                // iPhone: Use NavigationView
                iPhoneLayout
            }
        }
    }
    
    // iPad Layout with TabView
    private var iPadLayout: some View {
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
            
            TabView(selection: $selectedTab) {
                TunerView(
                    pitchManager: pitchManager,
                    noteConverter: noteConverter,
                    isListening: $isListening,
                    errorMessage: $errorMessage,
                    currentPitch: $currentPitch,
                    currentSpectrum: $currentSpectrum
                )
            }
            .tabItem {
                Image(systemName: "tuningfork")
                Text("Tuner")
            }
            .tag(0)
            
            MetronomeView(metronome: metronome)
                .tabItem {
                    Image(systemName: "timer")
                    Text("Metronome")
                }
                .tag(1)
        }
        .accentColor(.blue)
    }
    
    // iPhone Layout with NavigationView
    private var iPhoneLayout: some View {
        NavigationView {
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
                
                VStack {
                    if selectedTab == 0 {
                        GeometryReader { geo in
                            ScrollView {
                                TunerView(
                                    pitchManager: pitchManager,
                                    noteConverter: noteConverter,
                                    isListening: $isListening,
                                    errorMessage: $errorMessage,
                                    currentPitch: $currentPitch,
                                    currentSpectrum: $currentSpectrum
                                )
                                .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }
                    } else {
                        ScrollView {
                            MetronomeView(metronome: metronome)
                        }
                    }
                }
            }
            .navigationTitle(selectedTab == 0 ? "Tuner" : "Metronome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = 0
                            }
                        }) {
                            Image(systemName: "tuningfork")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(selectedTab == 0 ? .blue : .secondary)
                        }
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = 1
                            }
                        }) {
                            Image(systemName: "timer")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(selectedTab == 1 ? .blue : .secondary)
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
