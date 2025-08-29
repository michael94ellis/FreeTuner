//
//  TemperamentPickerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct TemperamentPickerView: View {
    @Bindable var noteConverter: NoteConverter
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemperament: Temperament
    private let temperamentConverter = TemperamentConverter()
    
    init(noteConverter: NoteConverter) {
        self.noteConverter = noteConverter
        self._selectedTemperament = State(initialValue: noteConverter.currentTemperament)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Temperament.allCases, id: \.self) { temperament in
                            TemperamentCardView(
                                temperament: temperament,
                                isSelected: selectedTemperament == temperament,
                                temperamentConverter: temperamentConverter,
                                onSelect: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedTemperament = temperament
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Temperament")
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
        .font(.system(size: 16, weight: .medium))
    }
    
    private var applyButton: some View {
        Button("Apply") {
            withAnimation(.easeInOut(duration: 0.2)) {
                noteConverter.currentTemperament = selectedTemperament
                dismiss()
            }
        }
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(.blue)
    }
}

#Preview {
    Group {
        TemperamentPickerView(noteConverter: NoteConverter())
            .preferredColorScheme(.light)
        
        TemperamentPickerView(noteConverter: NoteConverter())
            .preferredColorScheme(.dark)
    }
}
