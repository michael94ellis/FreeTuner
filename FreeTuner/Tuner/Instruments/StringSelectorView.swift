//
//  StringSelectorView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 9/19/26.
//

import SwiftUI
import DesignSystem

/// Shows each target string for the selected instrument as a top-border rail, highlights
/// whichever one is closest to the currently detected pitch, and lets the user tap a
/// string to hear its reference tone.
struct StringSelectorView: View {
    let instrument: Instrument
    let matchedStringID: String?
    let matchedCents: Int?
    let noteConverter: NoteConverter
    @ObservedObject var pitchPlayer: PitchPlayer
    @Binding var playingStringID: String?

    @Environment(\.isPad) private var isPad

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(instrument.strings.enumerated()), id: \.element.id) { index, string in
                stringCell(for: string, position: index)
            }
        }
    }

    @ViewBuilder
    private func stringCell(for string: InstrumentString, position: Int) -> some View {
        let isMatched = string.id == matchedStringID
        let isPlaying = playingStringID == string.id
        let isHighlighted = isMatched || isPlaying
        let borderColor: Color = isMatched ? (matchedCents?.centsColor ?? .accent) : (isPlaying ? .accent : .text.opacity(0.16))
        let labelColor: Color = isHighlighted ? .text : .textSecondary.opacity(0.6)
        let ordinal = ordinalLabel(instrument.strings.count - position)
        let octave = string.midiNote / 12 - 1

        Button {
            if isPlaying {
                pitchPlayer.stop()
                playingStringID = nil
            } else {
                pitchPlayer.play(frequency: noteConverter.frequency(forMidiNote: string.midiNote))
                playingStringID = string.id
            }
        } label: {
            VStack(spacing: 3) {
                Text("\(string.label)\(octave)")
                    .font(.system(size: isPad ? 18 : 15, weight: .bold, design: .monospaced))
                    .foregroundColor(labelColor)
                Text(ordinal)
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1)
                    .foregroundColor(.text.opacity(0.3))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, isPad ? 12 : 9)
            .padding(.bottom, isPad ? 10 : 8)
            .overlay(alignment: .top) {
                Rectangle().fill(borderColor).frame(height: 2)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(string.label) string, \(ordinal.lowercased())")
        .accessibilityValue(isMatched ? "Closest match, \(matchedCents?.formatCents ?? "")" : "")
        .accessibilityHint(isPlaying ? "Playing reference tone. Tap to stop." : "Plays a reference tone for this string")
    }

    private func ordinalLabel(_ n: Int) -> String {
        switch n {
        case 1: return "1ST"
        case 2: return "2ND"
        case 3: return "3RD"
        default: return "\(n)TH"
        }
    }
}

#Preview {
    Group {
        StringSelectorView(
            instrument: .guitarStandard,
            matchedStringID: Instrument.guitarStandard.strings[0].id,
            matchedCents: 3,
            noteConverter: NoteConverter(),
            pitchPlayer: PitchPlayer(),
            playingStringID: .constant(nil)
        )
        .padding()
        .background(Color.systemBackgroundColor)
        .preferredColorScheme(.light)

        StringSelectorView(
            instrument: .ukuleleStandard,
            matchedStringID: nil,
            matchedCents: nil,
            noteConverter: NoteConverter(),
            pitchPlayer: PitchPlayer(),
            playingStringID: .constant(Instrument.ukuleleStandard.strings[0].id)
        )
        .padding()
        .background(Color.systemBackgroundColor)
        .preferredColorScheme(.dark)
    }
}
