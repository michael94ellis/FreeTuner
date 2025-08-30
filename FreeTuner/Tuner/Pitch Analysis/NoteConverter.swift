//
//  NoteConverter.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import Foundation

@Observable
class NoteConverter {
    @ObservationIgnored
    private let temperamentConverter = TemperamentConverter()
    var currentTemperament: Temperament = .equal
    var currentKey: String = "C" // For just intonation
    
    /// Convert frequency to the closest musical note using current temperament
    func frequencyToNote(_ frequency: Float) -> Note? {
        return temperamentConverter.frequencyToNote(frequency, temperament: currentTemperament)
    }
    
    /// Get a human-readable string representation of the note
    func frequencyToNoteString(_ frequency: Float) -> String {
        guard let note = frequencyToNote(frequency) else {
            return "Unknown"
        }
        
        let octaveString = "\(note.octave)"
        let centsString = formatCents(note.cents)
        
        return "\(note.name)\(octaveString) \(centsString)"
    }
    
    /// Format cents deviation as a string
    private func formatCents(_ cents: Int) -> String {
        if cents == 0 {
            return "✓"
        } else if cents > 0 {
            return "+\(cents)¢"
        } else {
            return "\(cents)¢"
        }
    }
    
    /// Get cents deviation for a note in current temperament compared to equal temperament
    func getCentsDeviation(_ noteName: String) -> Int {
        return temperamentConverter.getCentsDeviation(noteName, temperament: currentTemperament)
    }
    
    /// Set the A4 reference frequency
    func setA4Frequency(_ frequency: Float) {
        temperamentConverter.setA4Frequency(frequency)
    }
    
    /// Get the current A4 reference frequency
    func getA4Frequency() -> Float {
        return temperamentConverter.a4Frequency
    }
    
    /// Set the A4 MIDI reference note
    func setA4MidiNote(_ midiNote: Int) {
        temperamentConverter.setA4MidiNote(midiNote)
    }
    
    /// Get the current A4 MIDI reference note
    func getA4MidiNote() -> Int {
        return temperamentConverter.a4MidiNote
    }
}
