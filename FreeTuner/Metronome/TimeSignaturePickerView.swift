//
//  TimeSignaturePickerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct TimeSignaturePickerView: View {
    @ObservedObject var metronome: Metronome
    @Environment(\.dismiss) private var dismiss
    
    let timeSignatures = Metronome.TimeSignature.allValues
    
    var body: some View {
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
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(timeSignatures, id: \.name) { signature in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    metronome.setTimeSignature(signature)
                                    dismiss()
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("\(signature.beats)/\(signature.noteValue)")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        if signature.name != "\(signature.beats)/\(signature.noteValue)" {
                                            Text(signature.name)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if metronome.timeSignature.beats == signature.beats &&
                                        metronome.timeSignature.noteValue == signature.noteValue {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 24, weight: .medium))
                                            .scaleEffect(1.1)
                                            .animation(.easeInOut(duration: 0.2), value: metronome.timeSignature)
                                    }
                                }
                                .foregroundColor(.primary)
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            metronome.timeSignature.beats == signature.beats &&
                                            metronome.timeSignature.noteValue == signature.noteValue ? 
                                            Color.blue.opacity(0.3) : Color.gray.opacity(0.1),
                                            lineWidth: metronome.timeSignature.beats == signature.beats &&
                                            metronome.timeSignature.noteValue == signature.noteValue ? 2 : 1
                                        )
                                )
                                .scaleEffect(metronome.timeSignature.beats == signature.beats &&
                                           metronome.timeSignature.noteValue == signature.noteValue ? 1.02 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: metronome.timeSignature)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Time Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                }
            }
        }
    }
}

#Preview {
    MetronomeView(metronome: Metronome())
        .padding()
}
