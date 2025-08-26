//
//  TemperamentPickerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct TemperamentPickerView: View {
    @ObservedObject var noteConverter: NoteConverter
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemperament: Temperament
    private let temperamentConverter = TemperamentConverter()
    
    init(noteConverter: NoteConverter) {
        self.noteConverter = noteConverter
        self._selectedTemperament = State(initialValue: noteConverter.getTemperament())
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
                    LazyVStack(spacing: 16) {
                        ForEach(Temperament.allCases, id: \.self) { temperament in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTemperament = temperament
                                }
                            }) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(temperament.rawValue)
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.primary)
                                            
                                            Text(temperament.description)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedTemperament == temperament {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 24, weight: .medium))
                                                .scaleEffect(1.1)
                                                .animation(.easeInOut(duration: 0.2), value: selectedTemperament)
                                        } else {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 24, weight: .medium))
                                                .scaleEffect(1.1)
                                                .animation(.easeInOut(duration: 0.2), value: selectedTemperament)
                                                .hidden()
                                        }
                                    }
                                    
                                    // Show cents deviation for each note in this temperament
                                    if temperament != .equal {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Deviations from Equal Temperament")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                            
                                            HStack(spacing: 12) {
                                                ForEach(["C", "D", "E", "F", "G", "A", "B"], id: \.self) { note in
                                                    let deviation = temperamentConverter.getCentsDeviation(note, temperament: temperament)
                                                    VStack(spacing: 4) {
                                                        Text(note)
                                                            .font(.system(size: 12, weight: .medium))
                                                            .foregroundColor(.secondary)
                                                        Text("\(deviation)")
                                                            .font(.system(size: 14, weight: .semibold))
                                                            .foregroundColor(deviation == 0 ? .green : .orange)
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 4)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                    .fill(deviation == 0 ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                                                            )
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.top, 4)
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
                                        .stroke(
                                            selectedTemperament == temperament ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1),
                                            lineWidth: selectedTemperament == temperament ? 2 : 1
                                        )
                                )
                                .scaleEffect(selectedTemperament == temperament ? 1.02 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: selectedTemperament)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Temperament")
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
                            noteConverter.setTemperament(selectedTemperament)
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
    TemperamentPickerView(noteConverter: NoteConverter())
}
