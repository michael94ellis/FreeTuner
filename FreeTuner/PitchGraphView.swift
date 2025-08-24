//
//  PitchGraphView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct PitchGraphView: View {
    let spectrum: [(frequency: Float, magnitude: Float)]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 1) {
                ForEach(Array(spectrum.enumerated()), id: \.offset) { index, point in
                    FrequencyBar(
                        magnitude: point.magnitude,
                        frequency: point.frequency,
                        maxMagnitude: spectrum.map { $0.magnitude }.max() ?? 1.0,
                        height: geometry.size.height
                    )
                }
            }
        }
        .frame(height: 200)
        .background(Color.black.opacity(0.05))
        .cornerRadius(8)
    }
}

struct FrequencyBar: View {
    let magnitude: Float
    let frequency: Float
    let maxMagnitude: Float
    let height: CGFloat
    
    private var barHeight: CGFloat {
        // Convert dB magnitude to a visual height
        // dB values are typically negative, so we normalize them
        let normalizedMagnitude = max(0, (magnitude + 80) / 80) // Assuming range from -80 to 0 dB
        return CGFloat(normalizedMagnitude) * height
    }
    
    private var barColor: Color {
        // Color based on frequency (musical note colors)
        let hue = (frequency / 4186.0) * 0.8 // Map frequency to hue (0-0.8)
        return Color(hue: Double(hue), saturation: 0.7, brightness: 0.8)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Rectangle()
                .fill(barColor)
                .frame(height: max(2, barHeight)) // Minimum 2pt height for visibility
                .animation(.easeInOut(duration: 0.1), value: barHeight)
        }
    }
}

struct FrequencyLabelsView: View {
    let spectrum: [(frequency: Float, magnitude: Float)]
    
    var body: some View {
        HStack {
            if let minFreq = spectrum.first?.frequency {
                Text("\(Int(minFreq)) Hz")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let maxFreq = spectrum.last?.frequency {
                Text("\(Int(maxFreq)) Hz")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

// Alternative view with logarithmic frequency scaling for better musical representation
struct MusicalPitchGraphView: View {
    let spectrum: [(frequency: Float, magnitude: Float)]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 1) {
                ForEach(Array(spectrum.enumerated()), id: \.offset) { index, point in
                    MusicalFrequencyBar(
                        magnitude: point.magnitude,
                        frequency: point.frequency,
                        maxMagnitude: spectrum.map { $0.magnitude }.max() ?? 1.0,
                        height: geometry.size.height
                    )
                }
            }
        }
        .frame(height: 200)
        .background(Color.black.opacity(0.05))
        .cornerRadius(8)
    }
}

struct MusicalFrequencyBar: View {
    let magnitude: Float
    let frequency: Float
    let maxMagnitude: Float
    let height: CGFloat
    
    private var barHeight: CGFloat {
        // Convert dB magnitude to a visual height
        let normalizedMagnitude = max(0, (magnitude + 80) / 80)
        return CGFloat(normalizedMagnitude) * height
    }
    
    private var barColor: Color {
        // Color based on musical note
        let note = frequencyToNote(frequency)
        return noteColor(note)
    }
    
    private func frequencyToNote(_ freq: Float) -> String {
        // Simple frequency to note conversion
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let a4 = 440.0
        let halfSteps = Int(round(12 * log2(Double(freq) / a4)))
        let octave = (halfSteps + 9) / 12 + 4
        let noteIndex = (halfSteps + 9) % 12
        return "\(notes[noteIndex])\(octave)"
    }
    
    private func noteColor(_ note: String) -> Color {
        // Color coding for musical notes
        let colors: [String: Color] = [
            "C": .red, "C#": .pink, "D": .orange, "D#": .yellow,
            "E": .green, "F": .blue, "F#": .purple, "G": .brown,
            "G#": .gray, "A": .red, "A#": .pink, "B": .orange
        ]
        
        let baseNote = String(note.prefix(note.count - 1))
        return colors[baseNote] ?? .gray
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Rectangle()
                .fill(barColor)
                .frame(height: max(2, barHeight))
                .animation(.easeInOut(duration: 0.1), value: barHeight)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Standard Frequency Spectrum")
            .font(.headline)
        
        PitchGraphView(spectrum: [
            (frequency: 100, magnitude: -20),
            (frequency: 200, magnitude: -40),
            (frequency: 300, magnitude: -10),
            (frequency: 400, magnitude: -30),
            (frequency: 500, magnitude: -50),
            (frequency: 600, magnitude: -25),
            (frequency: 700, magnitude: -35),
            (frequency: 800, magnitude: -15),
            (frequency: 900, magnitude: -45),
            (frequency: 1000, magnitude: -20)
        ])
        
        FrequencyLabelsView(spectrum: [
            (frequency: 100, magnitude: -20),
            (frequency: 200, magnitude: -40),
            (frequency: 300, magnitude: -10),
            (frequency: 400, magnitude: -30),
            (frequency: 500, magnitude: -50),
            (frequency: 600, magnitude: -25),
            (frequency: 700, magnitude: -35),
            (frequency: 800, magnitude: -15),
            (frequency: 900, magnitude: -45),
            (frequency: 1000, magnitude: -20)
        ])
        
        Text("Musical Note Spectrum")
            .font(.headline)
        
        MusicalPitchGraphView(spectrum: [
            (frequency: 261.63, magnitude: -20), // C4
            (frequency: 277.18, magnitude: -40), // C#4
            (frequency: 293.66, magnitude: -10), // D4
            (frequency: 311.13, magnitude: -30), // D#4
            (frequency: 329.63, magnitude: -50), // E4
            (frequency: 349.23, magnitude: -25), // F4
            (frequency: 369.99, magnitude: -35), // F#4
            (frequency: 392.00, magnitude: -15), // G4
            (frequency: 415.30, magnitude: -45), // G#4
            (frequency: 440.00, magnitude: -20)  // A4
        ])
    }
    .padding()
}
