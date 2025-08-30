//
//  MidiReferenceNoteTests.swift
//  FreeTunerTests
//
//  Created by Michael Ellis on 8/24/25.
//

import XCTest
@testable import FreeTuner

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
        let note1 = noteConverter.frequencyToNote(440.0)
        XCTAssertNotNil(note1)
        XCTAssertEqual(note1?.name, "A")
        XCTAssertEqual(note1?.octave, 4)
        
        // Test with C4 reference (MIDI 60)
        noteConverter.setA4MidiNote(60)
        let note2 = noteConverter.frequencyToNote(261.63)
        XCTAssertNotNil(note2)
        XCTAssertEqual(note2?.name, "C")
        XCTAssertEqual(note2?.octave, 4)
    }
}
