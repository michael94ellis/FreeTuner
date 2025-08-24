//
//  A4FrequencyPickerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct A4FrequencyPickerView: View {
    @ObservedObject var noteConverter: NoteConverter
    @Environment(\.dismiss) private var dismiss
    @State private var selectedA4Frequency: Float
    
    // Common A4 frequencies used throughout history
    let commonA4Frequencies: [(name: String, frequency: Float?)] = [
        ("Modern Standard (A440)", 440.0),
        ("Baroque (A415)", 415.0),
        ("Classical (A430)", 430.0),
        ("Verdi (A432)", 432.0),
        ("Historical (A409)", 409.0),
        ("Early Music (A392)", 392.0),
        ("Custom", nil)
    ]
    
    init(noteConverter: NoteConverter) {
        self.noteConverter = noteConverter
        self._selectedA4Frequency = State(initialValue: noteConverter.getA4Frequency())
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Current A4 Display
                VStack(spacing: 8) {
                    Text("Current A4 Frequency")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(selectedA4Frequency)) Hz")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Custom Frequency Slider
                VStack(spacing: 12) {
                    Text("Custom Frequency")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("400 Hz")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(
                            value: $selectedA4Frequency,
                            in: 400...480,
                            step: 1
                        )
                        .accentColor(.blue)
                        
                        Text("480 Hz")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(Int(selectedA4Frequency)) Hz")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Common Frequencies
                VStack(spacing: 12) {
                    Text("Common Standards")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(commonA4Frequencies, id: \.name) { standard in
                            Button(action: {
                                if let frequency = standard.frequency {
                                    selectedA4Frequency = frequency
                                }
                                // For custom, just keep the current slider value
                            }) {
                                VStack(spacing: 4) {
                                    Text(standard.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    
                                    if let frequency = standard.frequency {
                                        Text("\(Int(frequency)) Hz")
                                            .font(.title3)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                    } else {
                                        Text("Custom")
                                            .font(.title3)
                                            .fontWeight(.medium)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedA4Frequency == (standard.frequency ?? selectedA4Frequency) ? Color.blue.opacity(0.1) : Color(.systemGray5))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedA4Frequency == (standard.frequency ?? selectedA4Frequency) ? Color.blue : Color.clear, lineWidth: 2)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("A4 Frequency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        noteConverter.setA4Frequency(selectedA4Frequency)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    A4FrequencyPickerView(noteConverter: NoteConverter())
}
