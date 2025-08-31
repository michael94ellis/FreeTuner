//
//  TemperamentConverter.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/27/25.
//

import Foundation

@Observable
class TemperamentConverter {
    private(set) var a4Frequency: Float = 440.0
    private(set) var a4MidiNote: Int = 69
    
    // Note names in order
    private let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    /// Set the A4 reference frequency
    func setA4Frequency(_ frequency: Float) {
        a4Frequency = max(400.0, min(480.0, frequency)) // Limit to reasonable range
    }
    
    /// Set the A4 MIDI reference note
    func setA4MidiNote(_ midiNote: Int) {
        a4MidiNote = max(0, min(127, midiNote)) // Limit to valid MIDI range
    }
    
    // Equal temperament ratios (current implementation)
    private func equalTemperamentRatio(_ semitones: Int) -> Float {
        return pow(2.0, Float(semitones) / 12.0)
    }
    
    // Just intonation ratios (pure intervals)
    // Ratios relative to A4 (440 Hz)
    private func justIntonationRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            3.0/5.0,      // C (major sixth below A)
            16.0/25.0,    // C# (minor seventh below A)
            27.0/40.0,    // D (major second below A)
            18.0/25.0,    // D# (minor third below A)
            3.0/4.0,      // E (major third below A)
            4.0/5.0,      // F (perfect fourth below A)
            32.0/45.0,    // F# (augmented fourth below A)
            9.0/10.0,     // G (perfect fifth below A)
            24.0/25.0,    // G# (minor sixth below A)
            1.0,          // A (unison)
            27.0/25.0,    // A# (minor second above A)
            9.0/8.0       // B (major second above A)
        ]
        let index = ((semitones % 12) + 12) % 12 // Handle negative numbers properly
        return ratios[index]
    }
    
    // Pythagorean tuning ratios (based on perfect fifths)
    // Ratios relative to A4 (440 Hz)
    private func pythagoreanRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            16.0/27.0,     // C (major sixth below A)
            128.0/243.0,   // C# (minor seventh below A)
            8.0/9.0,       // D (major second below A)
            64.0/81.0,     // D# (minor third below A)
            4.0/5.0,       // E (major third below A)
            3.0/4.0,       // F (perfect fourth below A)
            512.0/729.0,   // F# (augmented fourth below A)
            2.0/3.0,       // G (perfect fifth below A)
            256.0/243.0,   // G# (minor sixth below A)
            1.0,           // A (unison)
            16.0/15.0,     // A# (minor second above A)
            9.0/8.0        // B (major second above A)
        ]
        let index = ((semitones % 12) + 12) % 12 // Handle negative numbers properly
        return ratios[index]
    }
    
    // Meantone temperament (1/4 comma meantone)
    private func meantoneRatio(_ semitones: Int) -> Float {
        // Quarter-comma meantone ratios - corrected values
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
    
    
    /// Get the frequency ratios array for the specified temperament
    func getRatio(temperament: Temperament) -> [Float] {
        switch temperament {
        case .equal:
            return (0..<12).map { equalTemperamentRatio($0) }
        case .just:
            return (0..<12).map { justIntonationRatio($0) }
        case .pythagorean:
            return (0..<12).map { pythagoreanRatio($0) }
        case .meantone:
            return (0..<12).map { meantoneRatio($0) }
        case .well:
            return (0..<12).map { wellTemperamentRatio($0) }
        case .kirnberger:
            return (0..<12).map { kirnbergerRatio($0) }
        case .werckmeister:
            return (0..<12).map { werckmeisterRatio($0) }
        case .young:
            return (0..<12).map { youngRatio($0) }
        case .quarterComma:
            return (0..<12).map { quarterCommaRatio($0) }
        }
    }
    
    /// Get the frequency ratio for a given semitone in the specified temperament
    func getRatio(for semitones: Int, temperament: Temperament) -> Float {
        let ratio: Float
        switch temperament {
        case .equal:
            ratio = equalTemperamentRatio(semitones)
        case .just:
            ratio = justIntonationRatio(semitones)
        case .pythagorean:
            ratio = pythagoreanRatio(semitones)
        case .meantone:
            ratio = meantoneRatio(semitones)
        case .well:
            ratio = wellTemperamentRatio(semitones)
        case .kirnberger:
            ratio = kirnbergerRatio(semitones)
        case .werckmeister:
            ratio = werckmeisterRatio(semitones)
        case .young:
            ratio = youngRatio(semitones)
        case .quarterComma:
            ratio = quarterCommaRatio(semitones)
        }
        
        return ratio
    }
    
    /// Convert frequency to the closest musical note using the specified temperament
    /// Equal Temperament only
    func frequencyToNote(_ frequency: Float, temperament: Temperament) -> Note? {
        if temperament != .equal {
            return noteFromFrequencyNonEqual(frequency, temperamentRatios: getRatio(temperament: temperament))
        }
        guard frequency > 0 else { return nil }
        guard frequency >= 20.0 && frequency <= 20000.0 else { return nil }

        // Step 1: Estimate MIDI note from frequency
        let midiNote = 12 * log2(frequency / a4Frequency) + Float(a4MidiNote)
        let roundedMidiNote = round(midiNote)
        guard roundedMidiNote >= 0 && roundedMidiNote <= 127 else { return nil }

        let semitonesFromA4 = Int(roundedMidiNote) - a4MidiNote
        let expectedRatio = getRatio(for: semitonesFromA4, temperament: temperament)
        
        // Ensure we have a valid ratio
        guard expectedRatio > 0 else { return nil }
        
        let expectedFrequency = a4Frequency * expectedRatio
        
        // Calculate cents deviation from the temperament's tuning
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
    
    /// For non-equal temperaments
    func noteFromFrequencyNonEqual(_ frequency: Float,
                                   temperamentRatios: [Float],
                                   referenceNote: Int? = nil,
                                   referenceFreq: Float? = nil) -> Note? {
        let refNote = referenceNote ?? a4MidiNote
        let refFreq = referenceFreq ?? a4Frequency
        guard frequency > 0 else { return nil }
        
        // Find the closest note by comparing with all possible notes in multiple octaves
        var closestNoteIndex: Int?
        var closestOctave: Int?
        var minDistance: Float = .greatestFiniteMagnitude
        var matchedFrequency: Float = 0.0

        // Check multiple octaves around the expected octave
        let expectedOctave = Int(floor(12 * log2(frequency / refFreq) + Float(refNote)) / 12.0)
        let octaveRange = (expectedOctave - 2)...(expectedOctave + 2)

        for octave in octaveRange {
            for i in 0..<temperamentRatios.count {
                let ratio = temperamentRatios[i]
                
                // Calculate the frequency for this note in this octave
                // The ratios are already relative to the reference note (A4)
                let octaveOffset = octave - 4 // A4 is in octave 4
                let scaledFreq = refFreq * ratio * pow(2.0, Float(octaveOffset))

                let distance = abs(frequency - scaledFreq)
                if distance < minDistance {
                    minDistance = distance
                    closestNoteIndex = i
                    closestOctave = octave
                    matchedFrequency = scaledFreq
                }
            }
        }

        guard let index = closestNoteIndex, let octave = closestOctave else { return nil }

        let noteName = noteNames[index]
        let cents = Int(round(1200 * log2(frequency / matchedFrequency)))

        return Note(
            name: noteName,
            octave: octave,
            frequency: frequency,
            cents: cents
        )
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
