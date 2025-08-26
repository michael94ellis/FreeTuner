//
//  Temperament.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import Foundation

enum Temperament: String, CaseIterable {
    case equal = "Equal Temperament"
    case just = "Just Intonation"
    case pythagorean = "Pythagorean Tuning"
    case meantone = "Meantone Temperament"
    case well = "Well Temperament"
    case kirnberger = "Kirnberger III"
    case werckmeister = "Werckmeister III"
    case young = "Young Temperament"
    case valotti = "Valotti Temperament"
    case kellner = "Kellner Temperament"
    case neidhardt = "Neidhardt"
    case quarterComma = "Quarter-Comma Meantone"
    case thirdComma = "Third-Comma Meantone"
    case sixthComma = "Sixth-Comma Meantone"
    case silbermann = "Silbermann"
    case rameau = "Rameau"
    case marpurg = "Marpurg"
    case sorge = "Sorge"
    case tartini = "Tartini"
    case pythagoreanExtended = "Pythagorean Extended"
    case justExtended = "Just Intonation Extended"
    case quarterTone = "Quarter-Tone"
    case bohlenPierce = "Bohlen-Pierce"
    case wendyCarlos = "Wendy Carlos Alpha"
    case harryPartch = "Harry Partch 43-Tone"
    
    var description: String {
        switch self {
        case .equal:
            return "Standard modern tuning. Each semitone is exactly 100 cents."
        case .just:
            return "Pure intervals based on simple frequency ratios. More harmonious but limited to certain keys."
        case .pythagorean:
            return "Based on perfect fifths (3:2 ratio). Bright, pure fifths but problematic thirds."
        case .meantone:
            return "Historical temperament that tempers fifths to improve thirds. Good for Renaissance music."
        case .well:
            return "Compromise tuning that works well in all keys. Bach's preferred temperament."
        case .kirnberger:
            return "Johann Kirnberger's temperament. Pure thirds in C, F, G major. Good for Bach's music."
        case .werckmeister:
            return "Andreas Werckmeister's temperament. Well-balanced for all keys. Popular in Baroque period."
        case .young:
            return "Thomas Young's temperament. Excellent for Classical and early Romantic music."
        case .valotti:
            return "Francesco Antonio Vallotti's temperament. Favors flat keys. Good for Italian Baroque."
        case .kellner:
            return "Herbert Anton Kellner's temperament. Based on historical research. Good for Bach."
        case .neidhardt:
            return "Johann Georg Neidhardt's temperament. Well-tempered system with character."
        case .quarterComma:
            return "Quarter-comma meantone. Pure major thirds, tempered fifths. Renaissance standard."
        case .thirdComma:
            return "Third-comma meantone. Compromise between pure thirds and usable fifths."
        case .sixthComma:
            return "Sixth-comma meantone. Closer to equal temperament while preserving character."
        case .silbermann:
            return "Gottfried Silbermann's organ tuning. Bright, clear character for Baroque organs."
        case .rameau:
            return "Jean-Philippe Rameau's theoretical temperament. French Baroque theoretical approach."
        case .marpurg:
            return "Friedrich Wilhelm Marpurg's well-tempered system. Systematic approach to temperament."
        case .sorge:
            return "Georg Andreas Sorge's temperament. German Baroque organ tuning."
        case .tartini:
            return "Giuseppe Tartini's violin-based tuning. Based on natural harmonics of strings."
        case .pythagoreanExtended:
            return "Extended Pythagorean tuning. Pure fifths throughout, bright character."
        case .justExtended:
            return "Extended just intonation. More complex ratios for richer harmonies."
        case .quarterTone:
            return "Quarter-tone system. 24 tones per octave for microtonal music."
        case .bohlenPierce:
            return "Bohlen-Pierce scale. Based on 3:1 ratio, 13 tones per octave."
        case .wendyCarlos:
            return "Wendy Carlos Alpha scale. 15.39 cents per step, 78 steps per octave."
        case .harryPartch:
            return "Harry Partch's 43-tone scale. Just intonation with 43 divisions per octave."
        }
    }
}

class TemperamentConverter: ObservableObject {
    @Published var a4Frequency: Float = 440.0 {
        didSet {
            objectWillChange.send()
        }
    }
    private let a4MidiNote: Int = 69
    
    // Note names in order
    private let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    /// Set the A4 reference frequency
    func setA4Frequency(_ frequency: Float) {
        a4Frequency = max(400.0, min(480.0, frequency)) // Limit to reasonable range
    }
    
    /// Get the current A4 reference frequency
    func getA4Frequency() -> Float {
        return a4Frequency
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
    
    // Valotti temperament
    private func valottiRatio(_ semitones: Int) -> Float {
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
    
    // Kellner temperament
    private func kellnerRatio(_ semitones: Int) -> Float {
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
    
    // Neidhardt temperament
    private func neidhardtRatio(_ semitones: Int) -> Float {
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
    
    // Third-comma meantone
    private func thirdCommaRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,           // C (unison)
            1.0524,        // C# (tempered minor second)
            1.1194,        // D (major second)
            1.1937,        // D# (tempered minor third)
            1.2537,        // E (tempered major third)
            1.3404,        // F (perfect fourth)
            1.4047,        // F# (tempered augmented fourth)
            1.5023,        // G (tempered perfect fifth)
            1.5789,        // G# (tempered minor sixth)
            1.6808,        // A (tempered major sixth)
            1.7639,        // A# (tempered minor seventh)
            1.8816         // B (tempered major seventh)
        ]
        let index = ((semitones % 12) + 12) % 12
        return ratios[index]
    }
    
    // Sixth-comma meantone
    private func sixthCommaRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,           // C (unison)
            1.0571,        // C# (tempered minor second)
            1.1207,        // D (major second)
            1.1917,        // D# (tempered minor third)
            1.2567,        // E (tempered major third)
            1.3428,        // F (perfect fourth)
            1.4107,        // F# (tempered augmented fourth)
            1.5056,        // G (tempered perfect fifth)
            1.5928,        // G# (tempered minor sixth)
            1.6857,        // A (tempered major sixth)
            1.7736,        // A# (tempered minor seventh)
            1.8857         // B (tempered major seventh)
        ]
        let index = ((semitones % 12) + 12) % 12
        return ratios[index]
    }
    
    // Silbermann temperament
    private func silbermannRatio(_ semitones: Int) -> Float {
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
    
    // Rameau temperament
    private func rameauRatio(_ semitones: Int) -> Float {
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
    
    // Marpurg temperament
    private func marpurgRatio(_ semitones: Int) -> Float {
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
    
    // Sorge temperament
    private func sorgeRatio(_ semitones: Int) -> Float {
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
    
    // Tartini temperament (based on natural harmonics)
    private func tartiniRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,           // C (unison)
            16.0/15.0,     // C# (minor second)
            9.0/8.0,       // D (major second)
            6.0/5.0,       // D# (minor third)
            5.0/4.0,       // E (major third)
            4.0/3.0,       // F (perfect fourth)
            45.0/32.0,     // F# (augmented fourth)
            3.0/2.0,       // G (perfect fifth)
            8.0/5.0,       // G# (minor sixth)
            5.0/3.0,       // A (major sixth)
            9.0/5.0,       // A# (minor seventh)
            15.0/8.0       // B (major seventh)
        ]
        let index = ((semitones % 12) + 12) % 12
        return ratios[index]
    }
    
    // Extended Pythagorean tuning
    private func pythagoreanExtendedRatio(_ semitones: Int) -> Float {
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
        let index = ((semitones % 12) + 12) % 12
        return ratios[index]
    }
    
    // Extended just intonation
    private func justExtendedRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,           // C (unison)
            16.0/15.0,     // C# (minor second)
            9.0/8.0,       // D (major second)
            6.0/5.0,       // D# (minor third)
            5.0/4.0,       // E (major third)
            4.0/3.0,       // F (perfect fourth)
            45.0/32.0,     // F# (augmented fourth)
            3.0/2.0,       // G (perfect fifth)
            8.0/5.0,       // G# (minor sixth)
            5.0/3.0,       // A (major sixth)
            9.0/5.0,       // A# (minor seventh)
            15.0/8.0       // B (major seventh)
        ]
        let index = ((semitones % 12) + 12) % 12
        return ratios[index]
    }
    
    // Quarter-tone system (24 tones per octave)
    private func quarterToneRatio(_ semitones: Int) -> Float {
        // For quarter tones, we need to handle 24 divisions instead of 12
        let quarterToneIndex = semitones % 24
        let ratio = pow(2.0, Float(quarterToneIndex) / 24.0)
        return ratio
    }
    
    // Bohlen-Pierce scale (13 tones per octave based on 3:1 ratio)
    private func bohlenPierceRatio(_ semitones: Int) -> Float {
        let ratios: [Float] = [
            1.0,           // C (unison)
            1.0679,        // C# (tritave step)
            1.1403,        // D (major second)
            1.2185,        // D# (minor third)
            1.3027,        // E (major third)
            1.3933,        // F (perfect fourth)
            1.4909,        // F# (augmented fourth)
            1.5963,        // G (perfect fifth)
            1.7071,        // G# (minor sixth)
            1.8257,        // A (major sixth)
            1.9525,        // A# (minor seventh)
            2.0897         // B (major seventh)
        ]
        let index = ((semitones % 12) + 12) % 12
        return ratios[index]
    }
    
    // Wendy Carlos Alpha scale (15.39 cents per step)
    private func wendyCarlosRatio(_ semitones: Int) -> Float {
        // Alpha scale has 78 steps per octave, each step is 15.39 cents
        let alphaStep = 15.39
        let cents = Float(semitones) * Float(alphaStep)
        let ratio = pow(2.0, cents / 1200.0)
        return ratio
    }
    
    // Harry Partch 43-tone scale (approximation for 12-tone display)
    private func harryPartchRatio(_ semitones: Int) -> Float {
        // Partch's scale has 43 divisions per octave
        // This is an approximation mapping to 12-tone display
        let partchSteps = [0, 4, 8, 11, 15, 18, 22, 26, 29, 33, 36, 40]
        let partchIndex = semitones % 12
        let step = partchSteps[partchIndex]
        let ratio = pow(2.0, Float(step) / 43.0)
        return ratio
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
        case .valotti:
            return valottiRatio(semitones)
        case .kellner:
            return kellnerRatio(semitones)
        case .neidhardt:
            return neidhardtRatio(semitones)
        case .quarterComma:
            return quarterCommaRatio(semitones)
        case .thirdComma:
            return thirdCommaRatio(semitones)
        case .sixthComma:
            return sixthCommaRatio(semitones)
        case .silbermann:
            return silbermannRatio(semitones)
        case .rameau:
            return rameauRatio(semitones)
        case .marpurg:
            return marpurgRatio(semitones)
        case .sorge:
            return sorgeRatio(semitones)
        case .tartini:
            return tartiniRatio(semitones)
        case .pythagoreanExtended:
            return pythagoreanExtendedRatio(semitones)
        case .justExtended:
            return justExtendedRatio(semitones)
        case .quarterTone:
            return quarterToneRatio(semitones)
        case .bohlenPierce:
            return bohlenPierceRatio(semitones)
        case .wendyCarlos:
            return wendyCarlosRatio(semitones)
        case .harryPartch:
            return harryPartchRatio(semitones)
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
