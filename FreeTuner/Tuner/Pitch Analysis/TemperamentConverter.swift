//
//  TemperamentConverter.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/27/25.
//

import Foundation

@Observable
class TemperamentConverter {
    var a4Frequency: Float = 440.0
    private let a4MidiNote: Int = 69
    
    // Note names in order
    private let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    /// Set the A4 reference frequency
    func setA4Frequency(_ frequency: Float) {
        a4Frequency = max(400.0, min(480.0, frequency)) // Limit to reasonable range
    }
    
    // Equal temperament ratios (current implementation)
    private func equalTemperamentRatio(_ semitones: Int) -> Float {
        return pow(2.0, Float(semitones) / 12.0)
    }
    
    // Just intonation ratios (pure intervals)
    private func justIntonationRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,      // C (unison)
            16.0/15.0, // C# (minor second)
            9.0/8.0,   // D (major second)
            6.0/5.0,   // D# (minor third)
            5.0/4.0,   // E (major third)
            4.0/3.0,   // F (perfect fourth)
            45.0/32.0, // F# (augmented fourth)
            3.0/2.0,   // G (perfect fifth)
            8.0/5.0,   // G# (minor sixth)
            5.0/3.0,   // A (major sixth)
            9.0/5.0,   // A# (minor seventh)
            15.0/8.0   // B (major seventh)
        ]
        let index = ((semitones % 12) + 12) % 12 // Handle negative numbers properly
        return ratios[index]
    }
    
    // Pythagorean tuning ratios (based on perfect fifths)
    private func pythagoreanRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,           // C (unison)
            256.0/243.0,   // C# (limma)
            9.0/8.0,       // D (major second)
            32.0/27.0,     // D# (minor third)
            81.0/64.0,     // E (major third)
            4.0/3.0,       // F (perfect fourth)
            729.0/512.0,   // F# (augmented fourth)
            3.0/2.0,       // G (perfect fifth)
            128.0/81.0,    // G# (minor sixth)
            27.0/16.0,     // A (major sixth)
            16.0/9.0,      // A# (minor seventh)
            243.0/128.0    // B (major seventh)
        ]
        let index = ((semitones % 12) + 12) % 12 // Handle negative numbers properly
        return ratios[index]
    }
    
    // Meantone temperament (1/4 comma meantone)
    private func meantoneRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,           // C (unison)
            1.0449,        // C# (tempered minor second)
            1.1180,        // D (major second)
            1.1963,        // D# (tempered minor third)
            1.2500,        // E (major third)
            1.3375,        // F (perfect fourth)
            1.3975,        // F# (tempered augmented fourth)
            1.4953,        // G (perfect fifth)
            1.5625,        // G# (tempered minor sixth)
            1.6719,        // A (major sixth)
            1.7487,        // A# (tempered minor seventh)
            1.8692         // B (major seventh)
        ]
        let index = ((semitones % 12) + 12) % 12 // Handle negative numbers properly
        return ratios[index]
    }
    
    // Well temperament (approximation of Bach's preferred tuning)
    private func wellTemperamentRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,           // C (unison)
            1.0595,        // C# (slightly tempered)
            1.1225,        // D (slightly sharp)
            1.1892,        // D# (tempered)
            1.2500,        // E (pure major third)
            1.3348,        // F (slightly flat)
            1.4142,        // F# (tempered)
            1.4983,        // G (slightly flat fifth)
            1.5802,        // G# (tempered)
            1.6667,        // A (pure major sixth)
            1.7818,        // A# (tempered)
            1.8750         // B (slightly sharp)
        ]
        let index = ((semitones % 12) + 12) % 12 // Handle negative numbers properly
        return ratios[index]
    }
    
    // Kirnberger III temperament
    private func kirnbergerRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,           // C (unison)
            1.0535,        // C# (tempered)
            1.125,         // D (pure major second)
            1.1852,        // D# (tempered)
            1.25,          // E (pure major third)
            1.3333,        // F (pure perfect fourth)
            1.4063,        // F# (tempered)
            1.5,           // G (pure perfect fifth)
            1.6,           // G# (tempered)
            1.6667,        // A (pure major sixth)
            1.7778,        // A# (tempered)
            1.875          // B (pure major seventh)
        ]
        let index = ((semitones % 12) + 12) % 12
        return ratios[index]
    }
    
    // Werckmeister III temperament
    private func werckmeisterRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,           // C (unison)
            1.0583,        // C# (tempered)
            1.125,         // D (pure major second)
            1.1852,        // D# (tempered)
            1.25,          // E (pure major third)
            1.3333,        // F (pure perfect fourth)
            1.4063,        // F# (tempered)
            1.5,           // G (pure perfect fifth)
            1.6,           // G# (tempered)
            1.6667,        // A (pure major sixth)
            1.7778,        // A# (tempered)
            1.875          // B (pure major seventh)
        ]
        let index = ((semitones % 12) + 12) % 12
        return ratios[index]
    }
    
    // Young temperament
    private func youngRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,           // C (unison)
            1.0595,        // C# (tempered)
            1.1225,        // D (slightly sharp)
            1.1892,        // D# (tempered)
            1.25,          // E (pure major third)
            1.3348,        // F (slightly flat)
            1.4142,        // F# (tempered)
            1.4983,        // G (slightly flat fifth)
            1.5802,        // G# (tempered)
            1.6667,        // A (pure major sixth)
            1.7818,        // A# (tempered)
            1.875          // B (pure major seventh)
        ]
        let index = ((semitones % 12) + 12) % 12
        return ratios[index]
    }
    
    // Quarter-comma meantone
    private func quarterCommaRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,           // C (unison)
            1.0449,        // C# (tempered minor second)
            1.1180,        // D (major second)
            1.1963,        // D# (tempered minor third)
            1.25,          // E (pure major third)
            1.3375,        // F (perfect fourth)
            1.3975,        // F# (tempered augmented fourth)
            1.4953,        // G (perfect fifth)
            1.5625,        // G# (tempered minor sixth)
            1.6719,        // A (major sixth)
            1.7487,        // A# (tempered minor seventh)
            1.8692         // B (major seventh)
        ]
        let index = ((semitones % 12) + 12) % 12
        return ratios[index]
    }
    
    /// Get the frequency ratio for a given semitone in the specified temperament
    func getRatio(for semitones: Int, temperament: Temperament) -> Float {
        switch temperament {
        case .equal:
            return equalTemperamentRatio(semitones)
        case .just:
            return justIntonationRatio(semitones)
        case .pythagorean:
            return pythagoreanRatio(semitones)
        case .meantone:
            return meantoneRatio(semitones)
        case .well:
            return wellTemperamentRatio(semitones)
        case .kirnberger:
            return kirnbergerRatio(semitones)
        case .werckmeister:
            return werckmeisterRatio(semitones)
        case .young:
            return youngRatio(semitones)
        case .quarterComma:
            return quarterCommaRatio(semitones)
        }
    }
    
    /// Convert frequency to the closest musical note using the specified temperament
    func frequencyToNote(_ frequency: Float, temperament: Temperament) -> Note? {
        guard frequency > 0 else { return nil }
        
        // Handle extremely low or high frequencies that are outside musical range
        // Musical range is roughly 20 Hz to 20,000 Hz
        guard frequency >= 20.0 && frequency <= 20000.0 else { return nil }
        
        // Calculate MIDI note number using equal temperament as reference
        let midiNote = 12 * log2(frequency / a4Frequency) + Float(a4MidiNote)
        let roundedMidiNote = round(midiNote)
        
        // Ensure MIDI note is within valid range (0-127)
        guard roundedMidiNote >= 0 && roundedMidiNote <= 127 else { return nil }
        
        // Calculate the expected frequency for this note in the chosen temperament
        let semitonesFromA4 = Int(roundedMidiNote) - a4MidiNote
        let expectedRatio = getRatio(for: semitonesFromA4, temperament: temperament)
        
        // Ensure we have a valid ratio
        guard expectedRatio > 0 else { return nil }
        
        let expectedFrequency = a4Frequency * expectedRatio
        
        // Calculate cents deviation from the temperament's tuning
        let cents = Int(round(1200 * log2(frequency / expectedFrequency)))
        
        // Extract note name and octave
        let noteIndex = Int(roundedMidiNote) % 12
        let octave = Int(roundedMidiNote) / 12 - 1 // C0 is MIDI note 12
        
        // Ensure note index is valid
        guard noteIndex >= 0 && noteIndex < noteNames.count else { return nil }
        
        let noteName = noteNames[noteIndex]
        
        return Note(
            name: noteName,
            octave: octave,
            frequency: frequency,
            cents: cents
        )
    }
    
    /// Get the frequency of a specific note in the specified temperament
    func noteToFrequency(_ noteName: String, octave: Int, temperament: Temperament) -> Float? {
        guard let noteIndex = noteNames.firstIndex(of: noteName.uppercased()) else {
            return nil
        }
        
        let midiNote = noteIndex + (octave + 1) * 12
        
        // Ensure MIDI note is within valid range (0-127)
        guard midiNote >= 0 && midiNote <= 127 else {
            return nil
        }
        
        let semitonesFromA4 = midiNote - a4MidiNote
        let ratio = getRatio(for: semitonesFromA4, temperament: temperament)
        
        // Ensure we have a valid ratio
        guard ratio > 0 else {
            return nil
        }
        
        return a4Frequency * ratio
    }
    
    /// Get cents deviation for a note in the specified temperament compared to equal temperament
    func getCentsDeviation(_ noteName: String, temperament: Temperament) -> Int {
        guard let noteIndex = noteNames.firstIndex(of: noteName.uppercased()) else {
            return 0
        }
        
        let equalRatio = equalTemperamentRatio(noteIndex)
        let temperamentRatio = getRatio(for: noteIndex, temperament: temperament)
        
        // Ensure both ratios are valid
        guard equalRatio > 0 && temperamentRatio > 0 else {
            return 0
        }
        
        return Int(round(1200 * log2(temperamentRatio / equalRatio)))
    }
}
