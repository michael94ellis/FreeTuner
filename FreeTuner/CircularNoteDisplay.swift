//
//  CircularNoteDisplay.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct CircularNoteDisplay: View {
    let detectedNote: Note?
    let isListening: Bool
    
    // Note names in order (like a clock face)
    private let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    // Octave range to display (typically guitar uses octaves 2-6)
    private let octaveRange = 2...6
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size * 0.35
            
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: size * 0.7, height: size * 0.7)
                
                // Note labels around the circle
                ForEach(0..<12, id: \.self) { noteIndex in
                    let angle = Double(noteIndex) * 30 - 90 // Start from top (12 o'clock)
                    let noteName = noteNames[noteIndex]
                    let x = center.x + cos(angle * .pi / 180) * (radius * 0.95)
                    let y = center.y + sin(angle * .pi / 180) * (radius * 0.95)
                    Text("\(noteName)")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(noteColor(for: noteName))
                        .position(x: x, y: y)
                }
                
                // Center indicator
                VStack(spacing: 4) {
                    if let note = detectedNote {
                        Text(note.name)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Octave: \(note.octave)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.secondary)
                        + Text(" ")
                        + Text("Cents: \(formatCents(note.cents))")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(centsColor(note.cents))
                        
                        Text("\(Int(note.frequency)) Hz")
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                    } else {
                        Text("?")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        Text("No Note")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Tuning indicator (needle)
                if let note = detectedNote {
                    let angle = noteAngle(for: note.name) + 90
                    let needleLength: CGFloat = radius * 0.90
                    
                    Rectangle()
                        .fill(centsColor(note.cents))
                        .frame(width: 3, height: needleLength)
                        .offset(y: -needleLength / 2)
                        .rotationEffect(.degrees(angle))
                        .animation(.easeInOut(duration: 0.1), value: note.cents)
                }
                
                // Pulse animation when listening
                if isListening {
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        .frame(width: size * 0.7, height: size * 0.7)
                        .scaleEffect(isListening ? 1.2 : 1.0)
                        .opacity(isListening ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false), value: isListening)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func noteAngle(for noteName: String) -> Double {
        guard let index = noteNames.firstIndex(of: noteName) else { return 0 }
        return Double(index) * 30 - 90 // Convert to degrees, starting from top
    }
    
    private func noteColor(for noteName: String, octave: Int = 0) -> Color {
        guard let detectedNote = detectedNote else { return .secondary }
        
        if detectedNote.name == noteName && detectedNote.octave == octave {
            return centsColor(detectedNote.cents)
        } else {
            return .secondary.opacity(0.6)
        }
    }
    
    private func centsColor(_ cents: Int) -> Color {
        let absCents = abs(cents)
        if absCents <= 5 {
            return .green
        } else if absCents <= 15 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func formatCents(_ cents: Int) -> String {
        if cents == 0 {
            return "✓"
        } else if cents > 0 {
            return "+\(cents)¢"
        } else {
            return "\(cents)¢"
        }
    }
}

#Preview {
    VStack {
        CircularNoteDisplay(
            detectedNote: Note(name: "A", octave: 4, frequency: 440.0, cents: 5),
            isListening: true
        )
        .frame(width: 300, height: 300)
        
        CircularNoteDisplay(
            detectedNote: nil,
            isListening: false
        )
        .frame(width: 300, height: 300)
    }
    .padding()
}
