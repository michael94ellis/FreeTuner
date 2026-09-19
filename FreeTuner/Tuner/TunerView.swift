//
//  TunerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI
import DesignSystem

struct TunerView: View {
    let pitchManager: AudioInputManager
    @Bindable var noteConverter: NoteConverter
    @Binding var isListening: Bool
    @Binding var errorMessage: String?
    @Binding var currentPitch: Float?
    @Binding var currentSpectrum: [FrequencyMagnitude]
    @Binding var currentDecibels: (rms: CGFloat, peak: CGFloat)

    @Environment(\.isPad) private var isPad

    @State private var pitchData: [PitchDataPoint] = []
    @State private var pitchDetectionTask: Task<Void, Never>?

    @StateObject private var stringReferencePlayer = PitchPlayer()
    @State private var playingStringID: String?
    @State private var showingProUpsell = false

    @AppStorage("showPitchGraph") private var showPitchGraph: Bool = true
    @AppStorage("showSignalStrength") private var showSignalStrength: Bool = true
    @AppStorage("showReferenceLabels") private var showReferenceLabels: Bool = true
    @AppStorage("useSharps") private var useSharps: Bool = true
    @AppStorage("maxPitchHistorySize") private var maxPitchHistorySize: Int = 100
    @AppStorage("selectedInstrumentID") private var selectedInstrumentID: String = Instrument.chromatic.id

    private var selectedInstrument: Instrument {
        Instrument.withID(selectedInstrumentID)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: isPad ? 20 : 14) {

                hudTopRow

                InstrumentSelectorView(selectedInstrumentID: $selectedInstrumentID)
                    .onChange(of: selectedInstrumentID) {
                        stringReferencePlayer.stop()
                        playingStringID = nil
                    }

                let instrument = selectedInstrument
                let stringMatch = instrument.isChromatic ? nil : currentPitch.flatMap {
                    noteConverter.closestString(to: $0, in: instrument)
                }

                if !instrument.isChromatic {
                    StringSelectorView(
                        instrument: instrument,
                        matchedStringID: stringMatch?.string.id,
                        matchedCents: stringMatch?.cents,
                        noteConverter: noteConverter,
                        pitchPlayer: stringReferencePlayer,
                        playingStringID: $playingStringID
                    )
                }

                let detectedNote: Note? = {
                    if let match = stringMatch {
                        let octave = match.string.midiNote / 12 - 1
                        return Note(name: match.string.label, octave: octave, frequency: currentPitch ?? 0, cents: match.cents)
                    }
                    return currentPitch.flatMap {
                        noteConverter.frequencyToNote($0, useSharps: useSharps)
                    }
                }()

                TunerCircleView(
                    detectedNote: detectedNote,
                    isListening: $isListening,
                    useSharps: useSharps,
                    showsStringGuidance: !instrument.isChromatic
                )
                .padding(.vertical, isPad ? 12 : 4)

                if showReferenceLabels {
                    bottomInfoBlock(detectedNote: detectedNote, instrument: instrument, stringMatch: stringMatch)
                }

                if showSignalStrength {
                    DecibelMeterView(decibels: currentDecibels, isListening: isListening)
                }

                if showPitchGraph {
                    PitchGraphView(pitchData: pitchData, isListening: isListening, maxDataPoints: maxPitchHistorySize)
                }

                errorMessageView

                Spacer()
            }
            .padding(.horizontal, isPad ? 32 : 20)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isListening {
                        pitchManager.stop()
                        isListening = false
                        currentSpectrum = []
                        pitchDetectionTask?.cancel()
                        pitchDetectionTask = nil
                    } else {
                        stringReferencePlayer.stop()
                        playingStringID = nil
                        startListening()
                    }
                }
            }
        }
        .background(Color.systemBackgroundColor)
        .onDisappear {
            stringReferencePlayer.stop()
            playingStringID = nil
        }
        .sheet(isPresented: $showingProUpsell) {
            ProUpsellView()
        }
    }

    // MARK: - Top Row
    private var hudTopRow: some View {
        HStack {
            HStack(spacing: 7) {
                Circle()
                    .fill(isListening ? Color.success : Color.textSecondary.opacity(0.35))
                    .frame(width: 8, height: 8)
                Text(isListening ? "Listening" : "Tap to Start")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.4)
                    .textCase(.uppercase)
                    .foregroundColor(.textSecondary.opacity(0.7))
            }
            Spacer()
            Text("A4 = \(Int(noteConverter.getA4Frequency())) Hz")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textSecondary.opacity(0.85))
        }
        .padding(.top, isPad ? 12 : 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isListening ? "Audio processing active" : "Tap to start listening")
        .accessibilityHint("Tap once to start or stop audio input for pitch detection")
        .accessibilityAddTraits(.allowsDirectInteraction)
    }

    // MARK: - Readouts + Signal + Pro Teaser
    @ViewBuilder
    private func bottomInfoBlock(detectedNote: Note?, instrument: Instrument, stringMatch: (string: InstrumentString, cents: Int)?) -> some View {
        VStack(spacing: 14) {
            HStack(alignment: .top) {
                readout(label: "Frequency", value: String(format: "%.1f", currentPitch ?? 0), unit: "Hz", alignment: .leading)
                Spacer()
                readout(label: "Cents", value: detectedNote?.cents.formatCents ?? "0", color: detectedNote?.cents.centsColor ?? .text, alignment: .center)
                Spacer()
                if instrument.isChromatic {
                    readout(label: "Input", value: String(format: "%.0f", currentDecibels.rms), unit: "dB", alignment: .trailing)
                } else if let stringMatch {
                    let targetHz = noteConverter.frequency(forMidiNote: stringMatch.string.midiNote)
                    readout(label: "Target", value: String(format: "%.1f", targetHz), unit: "Hz", alignment: .trailing)
                } else {
                    readout(label: "Target", value: "—", alignment: .trailing)
                }
            }

            signalBarRow

            proTeaserRow
        }
    }

    private func readout(label: String, value: String, unit: String? = nil, color: Color = .text, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 3) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .tracking(1)
                .textCase(.uppercase)
                .foregroundColor(.textSecondary.opacity(0.6))
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                if let unit {
                    Text(unit)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary.opacity(0.6))
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var signalBarRow: some View {
        HStack(spacing: 10) {
            Text("SIGNAL")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1)
                .foregroundColor(.textSecondary.opacity(0.6))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.fillSubtle)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(signalColor)
                        .frame(width: max(0, signalLevel) * geo.size.width)
                        .animation(.easeInOut(duration: 0.1), value: signalLevel)
                }
            }
            .frame(height: 3)
        }
    }

    private var signalLevel: CGFloat {
        let minDb: CGFloat = -100, maxDb: CGFloat = 0
        let clamped = max(minDb, min(maxDb, currentDecibels.rms))
        return (clamped - minDb) / (maxDb - minDb)
    }

    private var signalColor: Color {
        if currentDecibels.rms < -40 { return .success }
        if currentDecibels.rms < -20 { return .warning }
        if currentDecibels.rms < -10 { return .orange }
        return .destructive
    }

    private var proTeaserRow: some View {
        Button {
            showingProUpsell = true
        } label: {
            HStack(spacing: 10) {
                (Text("Record This Session ").fontWeight(.semibold).foregroundColor(.text)
                 + Text("— every note, octave & timing").foregroundColor(.textSecondary))
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer(minLength: 8)
                Text("PRO")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.4)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.accent, in: Capsule())
            }
            .padding(.top, 14)
            .overlay(alignment: .top) {
                Rectangle().fill(Color.text.opacity(0.10)).frame(height: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Record This Session, Pro feature")
        .accessibilityHint("Opens Tuner Gauge Pro details")
    }

    @ViewBuilder
    var errorMessageView: some View {
        if let error = errorMessage {
            Banner(title: "Error", message: error, tone: .error)
                .accessibilityLabel("Error")
                .accessibilityValue(error)
                .accessibilityAddTraits(.isStaticText)
        }
    }

    private func setupPitchDetection() {
        pitchDetectionTask = Task {
            guard let pitchStream = pitchManager.stream else { return }

            for await (pitch, spectrum, decibels) in pitchStream {
                await MainActor.run {
                    self.currentPitch = pitch > 0 ? pitch : nil
                    self.currentSpectrum = spectrum
                    self.currentDecibels = (rms: CGFloat(decibels.rms), peak: CGFloat(decibels.peak))

                    // Update pitch data for graph
                    if pitch > 0 {
                        let dataPoint = PitchDataPoint(
                            timestamp: Date(),
                            frequency: pitch
                        )

                        // Add new data point and maintain max data points
                        pitchData.append(dataPoint)
                        if pitchData.count > maxPitchHistorySize {
                            pitchData.removeFirst()
                        }
                    }
                }
            }
        }
    }

    private func startListening() {
        errorMessage = nil
        currentPitch = nil
        currentSpectrum = []
        currentDecibels = (-60.0, -60.0) // Reset decibel level
        pitchData = [] // Clear pitch data when starting
        setupPitchDetection()
        do {
            try pitchManager.start()
            isListening = true
        } catch {
            errorMessage = "Failed to start audio: \(error.localizedDescription)"
            assertionFailure("Audio engine failed to start: \(error)")
        }
    }
}

#Preview {
    Group {
        TunerView(
            pitchManager: AudioInputManager(),
            noteConverter: NoteConverter(),
            isListening: .constant(false),
            errorMessage: .constant(nil),
            currentPitch: .constant(nil),
            currentSpectrum: .constant([]),
            currentDecibels: .constant((-60.0, -60.0))
        )
        .preferredColorScheme(.light)

        TunerView(
            pitchManager: AudioInputManager(),
            noteConverter: NoteConverter(),
            isListening: .constant(true),
            errorMessage: .constant("Test error message"),
            currentPitch: .constant(440.0),
            currentSpectrum: .constant([]),
            currentDecibels: .constant((-25, -25))
        )
        .preferredColorScheme(.dark)
    }
}
