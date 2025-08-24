//
//  MetronomeView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct MetronomeView: View {
    @ObservedObject var metronome: Metronome
    @State private var showingTimeSignaturePicker = false
    @State private var isBPMExpanded = true
    @State private var isTimeSignatureExpanded = true
    @State private var isQuickBPMsExpanded = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Title
                Text("Metronome")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                // BPM Display
                VStack(spacing: 8) {
                    Text("\(metronome.bpm)")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text("BPM")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 10)
                
                // Beat Indicator
                VStack(spacing: 4) {
                    if metronome.isPlaying {
                        Text("Beat \(metronome.currentBeat) of \(metronome.timeSignature.beats)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Set accent pattern")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Tap circles to toggle accents")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                    
                    HStack(spacing: 4) {
                        ForEach(0...metronome.timeSignature.beats - 1, id: \.self) { beat in
                            VStack(spacing: 4) {
                                Text("\(beat + 1)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    metronome.toggleAccent(for: beat)
                                }) {
                                    Circle()
                                        .fill(beat == metronome.currentBeat - 1 ? Color.blue :
                                                metronome.isAccented(beatIndex: beat) ? Color.orange : Color.gray.opacity(0.3))
                                        .frame(width: 32, height: 32)
                                        .padding(12)
                                        .scaleEffect(beat == metronome.currentBeat - 1 ? 1.2 : 1.0)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                        )
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .animation(.easeInOut(duration: 0.1), value: metronome.currentBeat)
                                .animation(.easeInOut(duration: 0.2), value: metronome.accentedBeats)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                
                // BPM Slider Section
                DisclosureGroup("BPM Control", isExpanded: $isBPMExpanded) {
                    VStack(spacing: 12) {
                        // BPM Slider
                        HStack {
                            Text("40")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Slider(
                                value: Binding(
                                    get: { Double(metronome.bpm) },
                                    set: { metronome.setBPM(Int($0)) }
                                ),
                                in: 40...200,
                                step: 1
                            )
                            .accentColor(.blue)
                            
                            Text("200")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Time Signature Section
                DisclosureGroup("Time Signature", isExpanded: $isTimeSignatureExpanded) {
                    VStack(spacing: 12) {
                        Button(action: {
                            showingTimeSignaturePicker = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(metronome.timeSignature.beats)/\(metronome.timeSignature.noteValue)")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    if metronome.timeSignature.name != "\(metronome.timeSignature.beats)/\(metronome.timeSignature.noteValue)" {
                                        Text(metronome.timeSignature.name)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
                // Play/Stop Button
                Button(action: {
                    if metronome.isPlaying {
                        metronome.stop()
                    } else {
                        metronome.start()
                    }
                }) {
                    HStack {
                        Image(systemName: metronome.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title)
                        Text(metronome.isPlaying ? "Stop" : "Start")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(metronome.isPlaying ? Color.red : Color.green)
                    .cornerRadius(12)
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingTimeSignaturePicker) {
            TimeSignaturePickerView(metronome: metronome)
        }
    }
}
