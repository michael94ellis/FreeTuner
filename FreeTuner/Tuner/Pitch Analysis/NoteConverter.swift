//
//  NoteConverter.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import Foundation

@Observable
class NoteConverter {
    private(set) var a4Frequency: Float = 440.0
    private(set) var a4MidiNote: Int = 69
    
    // Note names in order
    private let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    /// Convert frequency to the closest musical note using equal temperament
    func frequencyToNote(_ frequency: Float) -> Note? {
        guard frequency > 0 else { return nil }
        guard frequency >= 20.0 && frequency <= 20000.0 else { return nil }

        // Step 1: Estimate MIDI note from frequency
        let midiNote = 12 * log2(frequency / a4Frequency) + Float(a4MidiNote)
        let roundedMidiNote = round(midiNote)
        guard roundedMidiNote >= 0 && roundedMidiNote <= 127 else { return nil }

        let semitonesFromA4 = Int(roundedMidiNote) - a4MidiNote
        let expectedRatio = pow(2.0, Float(semitonesFromA4) / 12.0)
        let expectedFrequency = a4Frequency * expectedRatio
        
        // Calculate cents deviation from equal temperament
        let cents = Int(round(1200 * log2(frequency / expectedFrequency)))
        
        // Extract note name and octave
        let noteIndex = Int(roundedMidiNote) % 12
        let octave = Int(roundedMidiNote) / 12 - 1
        guard noteIndex >= 0 && noteIndex < noteNames.count else { return nil }

        let noteName = noteNames[noteIndex]

        return Note(
            name: noteName,
            octave: octave,
            frequency: frequency,
            cents: cents
        )
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
    
    /// Set the A4 reference frequency
    func setA4Frequency(_ frequency: Float) {
        a4Frequency = frequency // Limit to reasonable range
    }
    
    /// Get the current A4 reference frequency
    func getA4Frequency() -> Float {
        return a4Frequency
    }
    
    /// Set the A4 MIDI reference note
    func setA4MidiNote(_ midiNote: Int) {
        a4MidiNote = max(0, min(127, midiNote)) // Limit to valid MIDI range
    }
    
    /// Get the current A4 MIDI reference note
    func getA4MidiNote() -> Int {
        return a4MidiNote
    }
}
