//
//  MidiReferencePickerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct MidiReferencePickerView: View {
    @Bindable var noteConverter: NoteConverter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPad) private var isPad
    @State private var selectedMidiNote: Int
    
    // Common MIDI reference notes used throughout history
    let commonMidiNotes: [(name: String, note: Int, description: String)] = [
        ("A4 (Standard)", 69, "Modern standard reference"),
        ("C4 (Middle C)", 60, "Middle C reference"),
        ("A3", 57, "Lower A reference"),
        ("C5", 72, "Higher C reference"),
        ("G4", 67, "G reference"),
        ("D4", 62, "D reference"),
    ]
    
    init(noteConverter: NoteConverter) {
        self.noteConverter = noteConverter
        self._selectedMidiNote = State(initialValue: noteConverter.getA4MidiNote())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        currentMidiNoteDisplay
                        customMidiNotePicker
                        commonStandardsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("MIDI Reference Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemGray6).opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Current MIDI Note Display
    private var currentMidiNoteDisplay: some View {
        VStack(spacing: 12) {
            Text("Current MIDI Reference Note")
                .font(isPad ? .body : .subheadline)
                .foregroundColor(.secondary)
            
            Text("\(midiNoteToName(selectedMidiNote)) (MIDI \(selectedMidiNote))")
                .font(isPad ? .system(size: 48) : .title)
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 2, x: 0, y: 1)
        }
        .largeCardStyle()
    }
    
    // MARK: - Custom MIDI Note Picker
    private var customMidiNotePicker: some View {
        VStack(spacing: 16) {
            Text("Custom MIDI Note")
                .font(isPad ? .title : .title3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Picker("MIDI Note", selection: $selectedMidiNote) {
                ForEach(0..<128, id: \.self) { midiNote in
                    Text("\(midiNoteToName(midiNote)) (MIDI \(midiNote))")
                        .tag(midiNote)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 120)
        }
        .largeCardStyle()
    }
    
    // MARK: - Common Standards Section
    private var commonStandardsSection: some View {
        VStack(spacing: 16) {
            Text("Common Reference Notes")
                .font(isPad ? .title : .title3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(commonMidiNotes, id: \.name) { standard in
                    MidiStandardButton(
                        standard: standard,
                        isSelected: selectedMidiNote == standard.note,
                        onSelect: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMidiNote = standard.note
                            }
                        }
                    )
                }
            }
        }
        .largeCardStyle()
    }
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }
    
    // MARK: - Helper Methods
    private func midiNoteToName(_ midiNote: Int) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let noteIndex = midiNote % 12
        let octave = (midiNote / 12) - 1
        return "\(noteNames[noteIndex])\(octave)"
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            cancelButton
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            applyButton
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
        .font(isPad ? .body : .callout)
    }
    
    private var applyButton: some View {
        Button("Apply") {
            withAnimation(.easeInOut(duration: 0.2)) {
                noteConverter.setA4MidiNote(selectedMidiNote)
                dismiss()
            }
        }
        .font(isPad ? .title : .title3)
        .foregroundColor(.blue)
    }
}

#Preview {
    Group {
        MidiReferencePickerView(noteConverter: NoteConverter())
            .preferredColorScheme(.light)
        
        MidiReferencePickerView(noteConverter: NoteConverter())
            .preferredColorScheme(.dark)
    }
}
