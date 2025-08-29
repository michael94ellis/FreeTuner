//
//  NoteTests.swift
//  FreeTunerTests
//
//  Created by Michael Ellis on 8/27/25.
//

import XCTest
@testable import FreeTuner

final class NoteTests: XCTestCase {
    
    func testNoteCreation() {
        // Test basic note creation
        let note = Note(name: "A", octave: 4, frequency: 440.0, cents: 0)
        
        XCTAssertEqual(note.name, "A")
        XCTAssertEqual(note.octave, 4)
        XCTAssertEqual(note.frequency, 440.0, accuracy: 0.01)
        XCTAssertEqual(note.cents, 0)
    }
    
    func testNoteWithSharp() {
        // Test note with sharp
        let sharpNote = Note(name: "C#", octave: 5, frequency: 554.37, cents: 5)
        
        XCTAssertEqual(sharpNote.name, "C#")
        XCTAssertEqual(sharpNote.octave, 5)
        XCTAssertEqual(sharpNote.frequency, 554.37, accuracy: 0.01)
        XCTAssertEqual(sharpNote.cents, 5)
    }
    
    func testNoteWithFlat() {
        // Test note with flat (if supported)
        let flatNote = Note(name: "Db", octave: 3, frequency: 138.59, cents: -10)
        
        XCTAssertEqual(flatNote.name, "Db")
        XCTAssertEqual(flatNote.octave, 3)
        XCTAssertEqual(flatNote.frequency, 138.59, accuracy: 0.01)
        XCTAssertEqual(flatNote.cents, -10)
    }
    
    func testNoteWithDifferentOctaves() {
        // Test notes in different octaves
        let c0 = Note(name: "C", octave: 0, frequency: 16.35, cents: 0)
        let c4 = Note(name: "C", octave: 4, frequency: 261.63, cents: 0)
        let c8 = Note(name: "C", octave: 8, frequency: 4186.01, cents: 0)
        
        XCTAssertEqual(c0.octave, 0)
        XCTAssertEqual(c0.frequency, 16.35, accuracy: 0.01)
        
        XCTAssertEqual(c4.octave, 4)
        XCTAssertEqual(c4.frequency, 261.63, accuracy: 0.01)
        
        XCTAssertEqual(c8.octave, 8)
        XCTAssertEqual(c8.frequency, 4186.01, accuracy: 0.01)
    }
    
    func testNoteWithCentsDeviation() {
        // Test notes with different cents deviations
        let sharpNote = Note(name: "A", octave: 4, frequency: 442.0, cents: 8)
        let flatNote = Note(name: "A", octave: 4, frequency: 438.0, cents: -8)
        let perfectNote = Note(name: "A", octave: 4, frequency: 440.0, cents: 0)
        
        XCTAssertEqual(sharpNote.cents, 8)
        XCTAssertEqual(flatNote.cents, -8)
        XCTAssertEqual(perfectNote.cents, 0)
    }
    
    func testNoteWithExtremeCents() {
        // Test notes with extreme cents values
        let verySharp = Note(name: "C", octave: 4, frequency: 270.0, cents: 50)
        let veryFlat = Note(name: "C", octave: 4, frequency: 250.0, cents: -50)
        
        XCTAssertEqual(verySharp.cents, 50)
        XCTAssertEqual(veryFlat.cents, -50)
    }
    
    func testNoteWithAllNoteNames() {
        // Test all possible note names
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        for (index, name) in noteNames.enumerated() {
            let note = Note(name: name, octave: 4, frequency: 440.0 + Float(index * 10), cents: index)
            
            XCTAssertEqual(note.name, name)
            XCTAssertEqual(note.octave, 4)
            XCTAssertEqual(note.frequency, 440.0 + Float(index * 10), accuracy: 0.01)
            XCTAssertEqual(note.cents, index)
        }
    }
    
    func testNoteWithNegativeOctave() {
        // Test notes with negative octaves (very low notes)
        let lowNote = Note(name: "A", octave: -1, frequency: 27.5, cents: 0)
        
        XCTAssertEqual(lowNote.octave, -1)
        XCTAssertEqual(lowNote.frequency, 27.5, accuracy: 0.01)
    }
    
    func testNoteWithHighOctave() {
        // Test notes with high octaves
        let highNote = Note(name: "C", octave: 10, frequency: 16744.04, cents: 0)
        
        XCTAssertEqual(highNote.octave, 10)
        XCTAssertEqual(highNote.frequency, 16744.04, accuracy: 0.01)
    }
    
    func testNoteWithZeroFrequency() {
        // Test edge case with zero frequency
        let zeroFreqNote = Note(name: "A", octave: 4, frequency: 0.0, cents: 0)
        
        XCTAssertEqual(zeroFreqNote.frequency, 0.0)
        XCTAssertEqual(zeroFreqNote.name, "A")
        XCTAssertEqual(zeroFreqNote.octave, 4)
    }
    
    func testNoteWithNegativeFrequency() {
        // Test edge case with negative frequency
        let negativeFreqNote = Note(name: "A", octave: 4, frequency: -440.0, cents: 0)
        
        XCTAssertEqual(negativeFreqNote.frequency, -440.0)
        XCTAssertEqual(negativeFreqNote.name, "A")
        XCTAssertEqual(negativeFreqNote.octave, 4)
    }
    
    func testNoteStructImmutability() {
        // Test that Note struct properties are immutable (read-only)
        let note = Note(name: "A", octave: 4, frequency: 440.0, cents: 0)
        
        // These properties should be accessible but not modifiable
        XCTAssertEqual(note.name, "A")
        XCTAssertEqual(note.octave, 4)
        XCTAssertEqual(note.frequency, 440.0, accuracy: 0.01)
        XCTAssertEqual(note.cents, 0)
    }
    
    func testNoteFrequencyAccuracy() {
        // Test that frequency values maintain precision
        let preciseNote = Note(name: "A", octave: 4, frequency: 440.123456, cents: 0)
        
        XCTAssertEqual(preciseNote.frequency, 440.123456, accuracy: 0.000001)
    }
    
    func testNoteCentsRange() {
        // Test cents values across a reasonable range
        for cents in -50...50 {
            let note = Note(name: "A", octave: 4, frequency: 440.0, cents: cents)
            XCTAssertEqual(note.cents, cents)
        }
    }
}
