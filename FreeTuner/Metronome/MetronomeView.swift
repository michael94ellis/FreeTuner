//
//  MetronomeView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct MetronomeView: View {
    @ObservedObject var metronome: LoopingMetronome
    @State private var showingTimeSignaturePicker = false
    @State private var isBPMExpanded = true
    @State private var isTimeSignatureExpanded = true
    @State private var isQuickBPMsExpanded = true
    
    // Helper function to get tempo name for a given BPM
    private func getTempoName(for bpm: Int) -> String? {
        switch bpm {
        case 20...40:
            return "Larghissimo"
        case 41...60:
            return "Largo"
        case 61...76:
            return "Adagio"
        case 77...108:
            return "Andante"
        case 109...132:
            return "Moderato"
        case 133...168:
            return "Allegro"
        case 169...200:
            return "Presto"
        case 201...208:
            return "Prestissimo"
        default:
            return nil
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Title with modern styling
            Text("Metronome")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 10)
            
            Spacer()
            
            // BPM Display with enhanced styling
            VStack(spacing: 12) {
                Text("\(Int(metronome.bpm))")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                HStack(spacing: 8) {
                    Text("BPM")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(.systemGray6))
                        )
                    
                    if let tempoName = getTempoName(for: Int(metronome.bpm)) {
                        Text(tempoName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(.vertical, 20)
            
            // Beat Indicator with modern design
            VStack(spacing: 16) {
                if metronome.isPlaying {
                    Text("Beat \(metronome.currentBeat) of \(metronome.timeSignature.beats)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                } else {
                    Text("Set accent pattern")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Text("Tap circles to toggle accents")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                HStack(spacing: 8) {
                    ForEach(0...metronome.timeSignature.beats - 1, id: \.self) { beat in
                        VStack(spacing: 6) {
                            Text("\(beat + 1)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    metronome.toggleAccent(for: beat)
                                }
                            }) {
                                Circle()
                                    .fill(
                                        beat == metronome.currentBeat - 1 ? 
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        metronome.isAccented(beatIndex: beat) ? 
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.orange, Color.red]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) : 
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(.systemGray5), Color(.systemGray4)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                    )
                                    .shadow(color: beat == metronome.currentBeat - 1 ? .blue.opacity(0.3) : .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    .scaleEffect(beat == metronome.currentBeat - 1 ? 1.1 : 1.0)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .animation(.easeInOut(duration: 0.1), value: metronome.currentBeat)
                            .animation(.easeInOut(duration: 0.2), value: metronome.accentedBeats)
                        }
                    }
                }
            }
            .padding(.vertical, 16)
            
            // BPM Slider Section with modern card design and tempo labels
            VStack(spacing: 16) {
                DisclosureGroup(
                    content: {
                        VStack(spacing: 16) {
                            // BPM Slider with tempo labels
                            VStack(spacing: 12) {
                                HStack {
                                    Text("40")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                                                    Slider(
                                    value: Binding(
                                        get: { metronome.bpm },
                                        set: { 
                                            let newBPM = $0
                                            if newBPM != metronome.bpm {
                                                // Stop metronome if it's playing when BPM changes
                                                if metronome.isPlaying {
                                                    metronome.stop()
                                                }
                                                metronome.setBPM(newBPM)
                                            }
                                        }
                                    ),
                                    in: 40...200,
                                    step: 1
                                )
                                    .accentColor(.blue)
                                    
                                    Text("200")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                
                                // Tempo labels below the slider
                                HStack(spacing: 0) {
                                    ForEach([
                                        (40, "Larghissimo"),
                                        (60, "Largo"),
                                        (76, "Adagio"),
                                        (108, "Andante"),
                                        (132, "Moderato"),
                                        (168, "Allegro"),
                                        (200, "Presto")
                                    ], id: \.0) { bpm, tempo in
                                        VStack(spacing: 4) {
                                            Text(tempo)
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                            
                                            Text("\(bpm)")
                                                .font(.system(size: 8, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.top, 12)
                    },
                    label: {
                        HStack {
                            Text("BPM Control")
                                .font(.system(size: 16, weight: .semibold))
                            
                            if let tempoName = getTempoName(for: Int(metronome.bpm)) {
                                Text("• \(tempoName)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                )
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                
                // Time Signature Section with modern card design
                DisclosureGroup("Time Signature", isExpanded: $isTimeSignatureExpanded) {
                    VStack(spacing: 16) {
                        Button(action: {
                            showingTimeSignaturePicker = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(metronome.timeSignature.beats)/\(metronome.timeSignature.noteValue)")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    if metronome.timeSignature.name != "\(metronome.timeSignature.beats)/\(metronome.timeSignature.noteValue)" {
                                        Text(metronome.timeSignature.name)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 12)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Enhanced Play/Stop Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if metronome.isPlaying {
                        metronome.stop()
                    } else {
                        metronome.start()
                    }
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: metronome.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                    
                    Text(metronome.isPlaying ? "Stop" : "Start")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: metronome.isPlaying ? 
                                    [Color.red, Color.red.opacity(0.8)] : 
                                    [Color.green, Color.green.opacity(0.8)]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: metronome.isPlaying ? .red.opacity(0.3) : .green.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                .scaleEffect(metronome.isPlaying ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: metronome.isPlaying)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingTimeSignaturePicker) {
            TimeSignaturePickerView(metronome: metronome)
        }
    }
}

#Preview {
    MetronomeView(metronome: LoopingMetronome())
}
