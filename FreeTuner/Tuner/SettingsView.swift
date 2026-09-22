//
//  SettingsView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI
import DesignSystem

struct SettingsView: View {
    @Bindable var noteConverter: NoteConverter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPad) private var isPad

    @State private var showingA4FrequencyPicker = false
    @State private var showingMidiReferencePicker = false
    @State private var showingProUpsell = false

    // MARK: - AppStorage Properties
    @AppStorage("showPitchGraph") private var showPitchGraph: Bool = true
    @AppStorage("showSignalStrength") private var showSignalStrength: Bool = true
    @AppStorage("showReferenceLabels") private var showReferenceLabels: Bool = true
    @AppStorage("useSharps") private var useSharps: Bool = true
    @AppStorage("maxPitchHistorySize") private var maxPitchHistorySize: Int = 100

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Settings")
                        .font(.system(size: isPad ? 36 : 30, weight: .bold))
                        .tracking(-0.5)
                        .foregroundColor(.text)
                        .padding(.top, 4)

                    proBanner

                    group("Pro Features") {
                        lockedRow(title: "Note Recorder", subtitle: "Record notes, octave & timing during a session")
                        lockedRow(title: "Extended Pitch History", subtitle: "Unlimited trail instead of the last few hundred points")
                    }

                    group("Display") {
                        toggleRow(title: "Pitch Graph", subtitle: "Show the real-time frequency trail", isOn: $showPitchGraph)
                        toggleRow(title: "Signal Strength", subtitle: "Show the audio level meter", isOn: $showSignalStrength)
                        toggleRow(title: "Reference Labels", subtitle: "Show frequency, cents & signal readouts", isOn: $showReferenceLabels)
                        toggleRow(title: "Use Sharps", subtitle: "Display notes using sharps or flats", isOn: $useSharps)
                    }

                    group("Pitch History") {
                        maxHistoryRow
                    }

                    group("Reference") {
                        navRow(title: "A4 Frequency", value: "\(Int(noteConverter.getA4Frequency())) Hz") {
                            showingA4FrequencyPicker = true
                        }
                        navRow(title: "MIDI Reference", value: midiNoteToName(noteConverter.getA4MidiNote())) {
                            showingMidiReferencePicker = true
                        }
                    }
                }
                .padding(.horizontal, isPad ? 32 : 20)
                .padding(.bottom, 32)
            }
            .background(Color.systemBackgroundColor)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(isPad ? .title2 : .title3)
                            .foregroundColor(.text)
                    }
                    .accessibilityLabel("Close settings")
                    .accessibilityHint("Closes the settings menu and returns to the tuner")
                }
            }
        }
        .sheet(isPresented: $showingA4FrequencyPicker) {
            A4FrequencyPickerView(noteConverter: noteConverter)
        }
        .sheet(isPresented: $showingMidiReferencePicker) {
            MidiReferencePickerView(noteConverter: noteConverter)
        }
        .sheet(isPresented: $showingProUpsell) {
            ProUpsellView()
        }
    }

    // MARK: - Pro Banner
    private var proBanner: some View {
        Button {
            showingProUpsell = true
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Tuner Gauge Pro")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.text)
                    Text("Session recording, pitch history, more tunings")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary.opacity(0.75))
                }
                Spacer(minLength: 8)
                Text("UPGRADE")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(Color.accent, in: Capsule())
            }
            .padding(.vertical, 16)
            .overlay(alignment: .top) { hairline }
            .overlay(alignment: .bottom) { hairline }
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }

    // MARK: - Groups & Rows
    @ViewBuilder
    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(1)
                .foregroundColor(.textSecondary.opacity(0.6))
                .padding(.bottom, 2)
            content()
        }
        .padding(.top, 18)
    }

    private var hairline: some View {
        Rectangle().fill(Color.text.opacity(0.10)).frame(height: 1)
    }

    private func toggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 15, weight: .medium)).foregroundColor(.text)
                Text(subtitle).font(.system(size: 12)).foregroundColor(.textSecondary.opacity(0.75))
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.accent)
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) { hairline }
        .accessibilityElement(children: .combine)
    }

    private func lockedRow(title: String, subtitle: String) -> some View {
        Button {
            showingProUpsell = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(title).font(.system(size: 15, weight: .medium)).foregroundColor(.textSecondary)
                        Text("PRO")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.4)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accent, in: Capsule())
                    }
                    Text(subtitle).font(.system(size: 12)).foregroundColor(.textSecondary.opacity(0.65))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textSecondary.opacity(0.5))
            }
            .padding(.vertical, 14)
            .overlay(alignment: .bottom) { hairline }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), Pro feature")
        .accessibilityHint("Opens Tuner Gauge Pro details")
    }

    private func navRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).font(.system(size: 15, weight: .medium)).foregroundColor(.text)
                Spacer()
                Text(value).font(.system(size: 15, design: .monospaced)).foregroundColor(.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textSecondary.opacity(0.5))
            }
            .padding(.vertical, 14)
            .overlay(alignment: .bottom) { hairline }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }

    private var maxHistoryRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Max History Size").font(.system(size: 15, weight: .medium)).foregroundColor(.text)
                    Text("Number of data points to keep in memory").font(.system(size: 12)).foregroundColor(.textSecondary.opacity(0.75))
                }
                Spacer()
                Text("\(maxPitchHistorySize)")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(.accent)
            }
            let maxValue: Double = isPad ? 1000 : 250
            Slider(
                value: Binding(
                    get: { Double(maxPitchHistorySize) },
                    set: { maxPitchHistorySize = Int($0) }
                ),
                in: 25...maxValue,
                step: 25
            )
            .tint(.accent)
            .accessibilityLabel("Maximum pitch history size")
            .accessibilityValue("\(maxPitchHistorySize) data points")
            .accessibilityHint("Adjusts how many pitch measurements to keep in memory")
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) { hairline }
    }

    // MARK: - Helper Methods
    private func midiNoteToName(_ midiNote: Int) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let noteIndex = midiNote % 12
        let octave = (midiNote / 12) - 1
        return "\(noteNames[noteIndex])\(octave)"
    }
}

#Preview {
    Group {
        SettingsView(noteConverter: NoteConverter())
            .preferredColorScheme(.light)

        SettingsView(noteConverter: NoteConverter())
            .preferredColorScheme(.dark)
    }
}
