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
                // Background circle with gradient
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(.systemBackground),
                                Color(.systemGray6).opacity(0.3)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.4
                        )
                    )
                    .frame(width: size * 0.8, height: size * 0.8)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Outer ring with tuning gradient
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                .green, .green.opacity(0.8), .orange, .red, .red.opacity(0.8), .orange, .green, .green
                            ]),
                            center: .center
                        ),
                        lineWidth: 6
                    )
                    .frame(width: size * 0.75, height: size * 0.75)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Beat segments with enhanced styling
                ForEach(0..<12, id: \.self) { i in
                    let startAngle = Angle(degrees: Double(i) * 30 - 105)
                    let endAngle = Angle(degrees: Double(i) * 30 - 75)
                    
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: radius * 0.85,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false
                        )
                    }
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 24
                    )
                }
                
                // Note labels around the circle with enhanced styling
                ForEach(0..<12, id: \.self) { noteIndex in
                    let angle = Double(noteIndex) * 30 - 90 // Start from top (12 o'clock)
                    let noteName = noteNames[noteIndex]
                    let x = center.x + cos(angle * .pi / 180) * (radius * 0.95)
                    let y = center.y + sin(angle * .pi / 180) * (radius * 0.95)
                    
                    Text("\(noteName)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(noteColor(for: noteName))
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                        .position(x: x, y: y)
                        .scaleEffect(noteColor(for: noteName) != .secondary.opacity(0.6) ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: detectedNote?.name)
                }
                
                // Center indicator
                VStack(spacing: 8) {
                    if let note = detectedNote {
                        Text(note.name)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        HStack(spacing: 16) {
                            VStack(spacing: 2) {
                                Text("Octave")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text("\(note.octave)")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(spacing: 2) {
                                Text("Cents")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text(formatCents(note.cents))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(centsColor(note.cents))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6).opacity(0.5))
                        )
                        
                        Text("\(Int(note.frequency)) Hz")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                    } else {
                        VStack(spacing: 8) {
                            Text("?")
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            
                            Text("No Note Detected")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6).opacity(0.5))
                                )
                        }
                    }
                }
                
                // Enhanced tuning indicator (needle)
                if let note = detectedNote {
                    let baseAngle = noteAngle(for: note.name)
                    let centsOffset = Double(note.cents) * 0.6 // 0.6 degrees per cent for fine tuning
                    let angle = baseAngle + centsOffset + 90
                    let needleLength: CGFloat = radius * 0.90
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    centsColor(note.cents),
                                    centsColor(note.cents).opacity(0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 4, height: needleLength)
                        .offset(y: -needleLength / 2)
                        .rotationEffect(.degrees(angle))
                        .shadow(color: centsColor(note.cents).opacity(0.5), radius: 3, x: 0, y: 1)
                        .animation(.easeInOut(duration: 0.2), value: note.cents)
                }
                
                // Enhanced pulse animation when listening
                if isListening {
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.4),
                                    Color.purple.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: size * 0.7, height: size * 0.7)
                        .scaleEffect(isListening ? 1.3 : 1.0)
                        .opacity(isListening ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isListening)
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.2),
                                    Color.purple.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: size * 0.6, height: size * 0.6)
                        .scaleEffect(isListening ? 1.5 : 1.0)
                        .opacity(isListening ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false).delay(0.5), value: isListening)
                }
            }
        }
    }
    
    private func noteAngle(for noteName: String) -> Double {
        guard let index = noteNames.firstIndex(of: noteName) else { return 0 }
        return Double(index) * 30 - 90 // Convert to degrees, starting from top
    }
    
    private func noteColor(for noteName: String, octave: Int = 0) -> Color {
        guard let detectedNote = detectedNote else { return .secondary.opacity(0.6) }
        
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
}
