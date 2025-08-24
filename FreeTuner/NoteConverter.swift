//
//  NoteConverter.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import Foundation

struct Note {
    let name: String
    let octave: Int
    let frequency: Float
    let cents: Int // Cents deviation from perfect pitch
}

class NoteConverter {
    // A4 is the reference note (440 Hz)
    private let a4Frequency: Float = 440.0
    private let a4MidiNote: Int = 69
    
    // Note names in order
    private let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    /// Convert frequency to the closest musical note
    func frequencyToNote(_ frequency: Float) -> Note? {
        guard frequency > 0 else { return nil }
        
        // Calculate MIDI note number
        let midiNote = 12 * log2(frequency / a4Frequency) + Float(a4MidiNote)
        let roundedMidiNote = round(midiNote)
        
        // Calculate cents deviation
        let cents = Int(round((midiNote - roundedMidiNote) * 100))
        
        // Extract note name and octave
        let noteIndex = Int(roundedMidiNote) % 12
        let octave = Int(roundedMidiNote) / 12 - 1 // C0 is MIDI note 12
        
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
    
    /// Get the frequency of a specific note
    func noteToFrequency(_ noteName: String, octave: Int) -> Float? {
        guard let noteIndex = noteNames.firstIndex(of: noteName.uppercased()) else {
            return nil
        }
        
        let midiNote = noteIndex + (octave + 1) * 12
        return a4Frequency * pow(2, Float(midiNote - a4MidiNote) / 12)
    }
    
    /// Check if a frequency is close to being in tune (within tolerance)
    func isInTune(_ frequency: Float, tolerance: Int = 10) -> Bool {
        guard let note = frequencyToNote(frequency) else { return false }
        return abs(note.cents) <= tolerance
    }
    
    /// Get tuning direction (sharper or flatter)
    func getTuningDirection(_ frequency: Float) -> String {
        guard let note = frequencyToNote(frequency) else { return "Unknown" }
        
        if note.cents == 0 {
            return "In Tune"
        } else if note.cents > 0 {
            return "Sharper"
        } else {
            return "Flatter"
        }
    }
}

// Extension for common note frequencies
extension NoteConverter {
    /// Common reference frequencies
    static let commonNotes: [String: Float] = [
        "A4": 440.0,
        "C4": 261.63,
        "D4": 293.66,
        "E4": 329.63,
        "F4": 349.23,
        "G4": 392.00,
        "B4": 493.88
    ]
    
    /// Get the closest standard note name for a frequency
    func getClosestStandardNote(_ frequency: Float) -> String? {
        guard let note = frequencyToNote(frequency) else { return nil }
        return "\(note.name)\(note.octave)"
    }
}
