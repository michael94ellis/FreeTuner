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
                .captionFont(isPad: false)
                .foregroundColor(.secondary)
            
            Text("\(midiNoteToName(selectedMidiNote)) (MIDI \(selectedMidiNote))")
                .mainNoteFont(isPad: false)
                .foregroundColor(.primary)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 2, x: 0, y: 1)
        }
        .padding(24)
        .background(currentMidiNoteBackground)
        .overlay(currentMidiNoteBorder)
    }
    
    private var currentMidiNoteBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 8, x: 0, y: 2)
    }
    
    private var currentMidiNoteBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
    }
    
    // MARK: - Custom MIDI Note Picker
    private var customMidiNotePicker: some View {
        VStack(spacing: 16) {
            Text("Custom MIDI Note")
                .subheadingFont(isPad: false)
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
        .padding(20)
        .background(customPickerBackground)
        .overlay(customPickerBorder)
    }
    
    private var customPickerBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var customPickerBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
    }
    
    // MARK: - Common Standards Section
    private var commonStandardsSection: some View {
        VStack(spacing: 16) {
            Text("Common Reference Notes")
                .subheadingFont(isPad: false)
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
        .padding(20)
        .background(commonStandardsBackground)
        .overlay(commonStandardsBorder)
    }
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }
    
    private var commonStandardsBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 8, x: 0, y: 2)
    }
    
    private var commonStandardsBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
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
        .bodyFont(isPad: false)
    }
    
    private var applyButton: some View {
        Button("Apply") {
            withAnimation(.easeInOut(duration: 0.2)) {
                noteConverter.setA4MidiNote(selectedMidiNote)
                dismiss()
            }
        }
        .subheadingFont(isPad: false)
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
