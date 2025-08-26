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
    ]
    
    init(noteConverter: NoteConverter) {
        self.noteConverter = noteConverter
        self._selectedA4Frequency = State(initialValue: noteConverter.getA4Frequency())
    }
    
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
                    VStack(spacing: 24) {
                        // Current A4 Display with enhanced styling
                        VStack(spacing: 12) {
                            Text("Current A4 Frequency")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(selectedA4Frequency)) Hz")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                        
                        // Custom Frequency Slider with enhanced styling
                        VStack(spacing: 16) {
                            Text("Custom Frequency")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text("400 Hz")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Slider(
                                    value: $selectedA4Frequency,
                                    in: 400...480,
                                    step: 1
                                )
                                .accentColor(.blue)
                                
                                Text("480 Hz")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("\(Int(selectedA4Frequency)) Hz")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
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
                        
                        // Common Frequencies with enhanced styling
                        VStack(spacing: 16) {
                            Text("Common Standards")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(commonA4Frequencies, id: \.name) { standard in
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if let frequency = standard.frequency {
                                                selectedA4Frequency = frequency
                                            }
                                        }
                                    }) {
                                        VStack(spacing: 8) {
                                            Text(standard.name)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                            
                                            if let frequency = standard.frequency {
                                                Text("\(Int(frequency)) Hz")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.primary)
                                            } else {
                                                Text("Custom")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .padding(16)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    selectedA4Frequency == (standard.frequency ?? selectedA4Frequency) ? 
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ) :
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray5)]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    selectedA4Frequency == (standard.frequency ?? selectedA4Frequency) ? 
                                                    Color.blue.opacity(0.3) : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                        .scaleEffect(selectedA4Frequency == (standard.frequency ?? selectedA4Frequency) ? 1.02 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: selectedA4Frequency)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
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
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("A4 Frequency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            noteConverter.setA4Frequency(selectedA4Frequency)
                            dismiss()
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    A4FrequencyPickerView(noteConverter: NoteConverter())
}
