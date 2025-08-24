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
            List {
                ForEach(Temperament.allCases, id: \.self) { temperament in
                    Button(action: {
                        selectedTemperament = temperament
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(temperament.rawValue)
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text(temperament.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                if selectedTemperament == temperament {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                }
                            }
                            
                            // Show cents deviation for each note in this temperament
                            if temperament != .equal {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Deviations from Equal Temperament:")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 8) {
                                        ForEach(["C", "D", "E", "F", "G", "A", "B"], id: \.self) { note in
                                            let deviation = temperamentConverter.getCentsDeviation(note, temperament: temperament)
                                            VStack(spacing: 2) {
                                                Text(note)
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                                Text("\(deviation)")
                                                    .font(.caption2)
                                                    .foregroundColor(deviation == 0 ? .green : .orange)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Temperament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        noteConverter.setTemperament(selectedTemperament)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    TemperamentPickerView(noteConverter: NoteConverter())
}
