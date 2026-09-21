//
//  MidiReferenceNoteTests.swift
//  FreeTunerTests
//
//  Created by Michael Ellis on 8/24/25.
//

import XCTest
@testable import TunerGauge

final class MidiReferenceNoteTests: XCTestCase {
    
    func testDefaultMidiReferenceNote() {
        let noteConverter = NoteConverter()
        XCTAssertEqual(noteConverter.getA4MidiNote(), 69, "Default MIDI reference note should be 69 (A4)")
    }
    
    func testSetMidiReferenceNote() {
        let noteConverter = NoteConverter()
        
        // Test setting to C4 (MIDI 60)
        noteConverter.setA4MidiNote(60)
        XCTAssertEqual(noteConverter.getA4MidiNote(), 60, "MIDI reference note should be set to 60")
        
        // Test setting to G4 (MIDI 67)
        noteConverter.setA4MidiNote(67)
        XCTAssertEqual(noteConverter.getA4MidiNote(), 67, "MIDI reference note should be set to 67")
    }
    
    func testMidiReferenceNoteBounds() {
        let noteConverter = NoteConverter()
        
        // Test lower bound
        noteConverter.setA4MidiNote(-10)
        XCTAssertEqual(noteConverter.getA4MidiNote(), 0, "MIDI reference note should be clamped to 0")
        
        // Test upper bound
        noteConverter.setA4MidiNote(200)
        XCTAssertEqual(noteConverter.getA4MidiNote(), 127, "MIDI reference note should be clamped to 127")
    }
    
    func testFrequencyToNoteWithDifferentMidiReference() {
        let noteConverter = NoteConverter()
        
        // Test with default A4 reference (MIDI 69)
        noteConverter.setA4MidiNote(69)
        let note1 = noteConverter.frequencyToNote(440.0, useSharps: true)
        XCTAssertNotNil(note1)
        XCTAssertEqual(note1?.name, "A")
        XCTAssertEqual(note1?.octave, 4)
        
        // Test with C4 reference (MIDI 60). The reference frequency stays at
        // 440 Hz, but it now describes the pitch of C4 instead of A4, so
        // feeding that same 440 Hz back in should resolve to C4.
        noteConverter.setA4MidiNote(60)
        let note2 = noteConverter.frequencyToNote(440.0, useSharps: true)
        XCTAssertNotNil(note2)
        XCTAssertEqual(note2?.name, "C")
        XCTAssertEqual(note2?.octave, 4)
    }

    func testActualA4FrequencyMatchesStoredFrequencyWhenReferenceIsA4() {
        let noteConverter = NoteConverter()

        // Default reference note is A4 (MIDI 69), so the actual A4 frequency
        // should equal whatever was stored directly.
        noteConverter.setA4Frequency(432.0)
        XCTAssertEqual(noteConverter.getActualA4Frequency(), 432.0, accuracy: 0.01)
    }

    func testActualA4FrequencyConvertsFromNonA4Reference() {
        let noteConverter = NoteConverter()

        // If the reference note is shifted to C4 while the stored reference
        // frequency stays 440 Hz, that 440 Hz now describes C4, not A4.
        // A4 is 9 semitones above C4, so the implied A4 frequency is
        // 440 * 2^(9/12) ≈ 739.99 Hz.
        noteConverter.setA4Frequency(440.0)
        noteConverter.setA4MidiNote(60)
        XCTAssertEqual(noteConverter.getActualA4Frequency(), 739.99, accuracy: 0.5)
    }
}
