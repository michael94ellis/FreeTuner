//
//  TunerCircleView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct TunerCircleView: View {
    let detectedNote: Note?
    @Binding var isListening: Bool
    @Environment(\.isPad) private var isPad
    
    // Note names in order (like a clock face)
    private let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size * 0.4
            
            ZStack {
                
                // Main tuning ring
                tuningRing(size: size, center: center, radius: radius)
                
                // Note markers around the ring
                noteMarkers(size: size, center: center, radius: radius)
                
                // Center display
                centerDisplay(size: size)
                
                // Tuning indicator
                tuningIndicator(size: size, center: center, radius: radius)
            }
        }
    }
    
    // MARK: - Tuning Ring
    @ViewBuilder
    private func tuningRing(size: CGFloat, center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            // Inner ring for visual depth
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemGray5),
                            Color(.systemGray6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: size * 0.7, height: size * 0.7)
            
            // Center circle for note display
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(.systemBackground),
                            Color(.systemGray6).opacity(0.5)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.25
                    )
                )
                .frame(width: size * 0.5, height: size * 0.5)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Note Markers
    @ViewBuilder
    private func noteMarkers(size: CGFloat, center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<12, id: \.self) { noteIndex in
            let angle = Double(noteIndex) * 30 - 90 // Start from top
            let noteName = noteNames[noteIndex]
            let x = center.x + cos(angle * .pi / 180) * (radius * 0.9)
            let y = center.y + sin(angle * .pi / 180) * (radius * 0.9)
            
            ZStack {
                // Prominent note marker dot
                Circle()
                    .fill(noteColor(for: noteName))
                    .frame(width: 16, height: 16)
                    .scaleEffect(noteColor(for: noteName) != .secondary.opacity(0.4) ? 1.3 : 1.0)
                    .shadow(color: noteColor(for: noteName).opacity(0.5), radius: 3, x: 0, y: 1)
                    .animation(.easeInOut(duration: 0.3), value: detectedNote?.name)
                
                // Note name with background
                Text(noteName)
                    .noteMarkerFont(isPad: isPad)
                    .foregroundColor(noteColor(for: noteName))
                    .padding(.horizontal, isPad ? 12 : 8)
                    .padding(.vertical, isPad ? 6 : 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground).opacity(0.9))
                            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 2, x: 0, y: 1)
                    )
                    .scaleEffect(noteColor(for: noteName) != .secondary.opacity(0.4) ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: detectedNote?.name)
            }
            .position(x: x, y: y)
        }
    }
    
    // MARK: - Center Display
    @ViewBuilder
    private func centerDisplay(size: CGFloat) -> some View {
        VStack(spacing: 16) {
            if let note = detectedNote {
                // Main note display
                VStack(spacing: 8) {
                                    Text(note.name)
                    .mainNoteFont(isPad: isPad)
                    .foregroundColor(.primary)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 2, x: 0, y: 1)
                }
            } else {
                // No note detected state
                VStack(spacing: 12) {
                    Image(systemName: "music.note")
                        .iconFont(isPad: isPad)
                        .foregroundColor(.secondary)
                    
                    Text("No Note Detected")
                        .subheadingFont(isPad: isPad)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Tuning Indicator
    @ViewBuilder
    private func tuningIndicator(size: CGFloat, center: CGPoint, radius: CGFloat) -> some View {
        if let note = detectedNote {
            let baseAngle = noteAngle(for: note.name)
            let centsOffset = Double(note.cents) * 0.6 // 0.6 degrees per cent
            let angle = baseAngle + centsOffset + 90
            let needleLength: CGFloat = radius * 0.85
            
            // Tuning needle
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            note.cents.centsColor,
                            note.cents.centsColor.opacity(0.8)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 6, height: needleLength)
                .offset(y: -needleLength / 2)
                .rotationEffect(.degrees(angle))
                .shadow(color: note.cents.centsColor.opacity(0.3), radius: 4, x: 0, y: 2)
                .animation(.easeInOut(duration: 0.3), value: note.cents)
                .zIndex(-1)
        }
    }
    
    // MARK: - Helper Methods
    private func noteAngle(for noteName: String) -> Double {
        guard let index = noteNames.firstIndex(of: noteName) else { return 0 }
        return Double(index) * 30 - 90
    }
    
    private func noteColor(for noteName: String) -> Color {
        guard let detectedNote = detectedNote else { return .secondary.opacity(0.4) }
        
        if detectedNote.name == noteName {
            return detectedNote.cents.centsColor
        } else {
            return .secondary.opacity(0.4)
        }
    }
}

#Preview {
    Group {
        VStack(spacing: 20) {
            TunerCircleView(
                detectedNote: Note(name: "A", octave: 4, frequency: 440.0, cents: 5),
                isListening: .constant(true)
            )
            .frame(width: 300, height: 300)
            
            TunerCircleView(
                detectedNote: nil,
                isListening: .constant(false)
            )
            .frame(width: 300, height: 300)
        }
        .padding()
        .preferredColorScheme(.light)
        
        VStack(spacing: 20) {
            TunerCircleView(
                detectedNote: Note(name: "A", octave: 4, frequency: 440.0, cents: 5),
                isListening: .constant(false)
            )
            .frame(width: 300, height: 300)
            
            TunerCircleView(
                detectedNote: nil,
                isListening: .constant(false)
            )
            .frame(width: 300, height: 300)
        }
        .padding()
        .preferredColorScheme(.dark)
    }
}
