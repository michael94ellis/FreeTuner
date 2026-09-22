//
//  Instrument.swift
//  FreeTuner
//
//  Created by Michael Ellis on 9/19/26.
//

import Foundation

/// A single target string/course on a fretted or bowed instrument.
struct InstrumentString: Identifiable, Hashable {
    var id: String { "\(label)-\(midiNote)" }
    /// The natural-language name shown to the user, e.g. "E" or "Low E".
    let label: String
    /// The MIDI note number this string should be tuned to.
    let midiNote: Int
}

/// A preset instrument tuning: an ordered set of target strings, low to high.
struct Instrument: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let strings: [InstrumentString]

    var isChromatic: Bool { strings.isEmpty }
}

extension Instrument {
    static let chromatic = Instrument(
        id: "chromatic",
        name: "Chromatic",
        icon: "tuningfork",
        strings: []
    )

    static let guitarStandard = Instrument(
        id: "guitarStandard",
        name: "Guitar",
        icon: "guitars",
        strings: [
            InstrumentString(label: "E", midiNote: 40), // E2
            InstrumentString(label: "A", midiNote: 45), // A2
            InstrumentString(label: "D", midiNote: 50), // D3
            InstrumentString(label: "G", midiNote: 55), // G3
            InstrumentString(label: "B", midiNote: 59), // B3
            InstrumentString(label: "E", midiNote: 64), // E4
        ]
    )

    static let guitarDropD = Instrument(
        id: "guitarDropD",
        name: "Guitar (Drop D)",
        icon: "guitars",
        strings: [
            InstrumentString(label: "D", midiNote: 38), // D2
            InstrumentString(label: "A", midiNote: 45), // A2
            InstrumentString(label: "D", midiNote: 50), // D3
            InstrumentString(label: "G", midiNote: 55), // G3
            InstrumentString(label: "B", midiNote: 59), // B3
            InstrumentString(label: "E", midiNote: 64), // E4
        ]
    )

    static let bassStandard = Instrument(
        id: "bassStandard",
        name: "Bass",
        icon: "guitars",
        strings: [
            InstrumentString(label: "E", midiNote: 28), // E1
            InstrumentString(label: "A", midiNote: 33), // A1
            InstrumentString(label: "D", midiNote: 38), // D2
            InstrumentString(label: "G", midiNote: 43), // G2
        ]
    )

    static let ukuleleStandard = Instrument(
        id: "ukuleleStandard",
        name: "Ukulele",
        icon: "music.note",
        strings: [
            InstrumentString(label: "G", midiNote: 67), // G4 (re-entrant)
            InstrumentString(label: "C", midiNote: 60), // C4
            InstrumentString(label: "E", midiNote: 64), // E4
            InstrumentString(label: "A", midiNote: 69), // A4
        ]
    )

    static let violinStandard = Instrument(
        id: "violinStandard",
        name: "Violin",
        icon: "music.quarternote.3",
        strings: [
            InstrumentString(label: "G", midiNote: 55), // G3
            InstrumentString(label: "D", midiNote: 62), // D4
            InstrumentString(label: "A", midiNote: 69), // A4
            InstrumentString(label: "E", midiNote: 76), // E5
        ]
    )

    /// All selectable instruments, in the order shown in the picker.
    static let all: [Instrument] = [
        .chromatic,
        .guitarStandard,
        .guitarDropD,
        .bassStandard,
        .ukuleleStandard,
        .violinStandard,
    ]

    static func withID(_ id: String) -> Instrument {
        all.first { $0.id == id } ?? .chromatic
    }
}
