//
//  TunerCircleView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI
import DesignSystem

/// Analog-style tuner gauge: a digital note readout above a dial with a
/// smoothly-swinging needle, like a classic clip-on tuner face.
struct TunerCircleView: View {
    let detectedNote: Note?
    @Binding var isListening: Bool
    let useSharps: Bool
    /// When true, the verdict includes string-tensioning language ("LOOSEN"/"TIGHTEN").
    var showsStringGuidance: Bool = false
    @Environment(\.isPad) private var isPad

    /// Full-scale range of the dial. A semitone is 100 cents, so ±50¢ covers the
    /// whole gap between two adjacent notes.
    private let fullScaleCents: Double = 50
    private let sweepDegrees: Double = 48

    var body: some View {
        VStack(spacing: isPad ? 18 : 12) {
            bigNoteDisplay
            dial
            verdictLabel
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Big Note
    private var bigNoteDisplay: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(detectedNote?.name ?? "–")
                .font(.system(size: isPad ? 76 : 54, weight: .bold))
                .tracking(-2)
                .foregroundColor(.text)
            if let note = detectedNote {
                Text("\(note.octave)")
                    .font(.system(size: isPad ? 26 : 19, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .padding(.bottom, isPad ? 10 : 6)
            }
        }
        .contentTransition(.numericText())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Detected note")
        .accessibilityValue(detectedNote != nil ? "\(detectedNote!.name)\(detectedNote!.octave)" : "No note detected")
        .accessibilityHint("Shows the currently detected musical note")
        .accessibilityAddTraits(.updatesFrequently)
    }

    // MARK: - Dial
    private var needleAngle: Double {
        let cents = min(max(Double(detectedNote?.cents ?? 0), -fullScaleCents), fullScaleCents)
        return cents / fullScaleCents * sweepDegrees
    }

    private var dial: some View {
        ZStack(alignment: .bottom) {
            dialFace
            GaugeNeedle()
                .fill(pointerColor)
                .frame(width: isPad ? 16 : 12, height: isPad ? 190 : 140)
                .rotationEffect(.degrees(needleAngle), anchor: .bottom)
                .animation(.easeOut(duration: 0.18), value: needleAngle)
                .shadow(color: pointerColor.opacity(0.35), radius: 4, y: -2)
        }
        .frame(height: isPad ? 210 : 156)
        .accessibilityHidden(true)
    }

    private var dialFace: some View {
        Canvas { context, size in
            let pivot = CGPoint(x: size.width / 2, y: size.height)
            let radius = min(size.width / 2, size.height) - (isPad ? 22 : 16)

            func point(angle: Double, radius: CGFloat) -> CGPoint {
                let rad = (angle - 90) * .pi / 180
                return CGPoint(x: pivot.x + radius * cos(rad), y: pivot.y + radius * sin(rad))
            }

            // Face arc
            var face = Path()
            face.addArc(center: pivot, radius: radius, startAngle: .degrees(-sweepDegrees - 90), endAngle: .degrees(sweepDegrees - 90), clockwise: false)
            context.stroke(face, with: .color(Color.text.opacity(0.12)), lineWidth: 2)

            // In-tune zone highlight
            let tolAngle = Double(CentsTolerance) / fullScaleCents * sweepDegrees
            var zone = Path()
            zone.addArc(center: pivot, radius: radius, startAngle: .degrees(-tolAngle - 90), endAngle: .degrees(tolAngle - 90), clockwise: false)
            context.stroke(zone, with: .color(Color.success.opacity(0.6)), lineWidth: 3)

            // Ticks every 10¢
            let step = 10
            for tick in stride(from: -Int(fullScaleCents), through: Int(fullScaleCents), by: step) {
                let angle = Double(tick) / fullScaleCents * sweepDegrees
                let isMajor = tick == 0 || abs(tick) == Int(fullScaleCents)
                let outer = point(angle: angle, radius: radius)
                let inner = point(angle: angle, radius: radius - (isMajor ? 14 : 8))
                var tickPath = Path()
                tickPath.move(to: inner)
                tickPath.addLine(to: outer)
                let tickColor: Color = tick == 0 ? Color.text.opacity(0.55) : Color.text.opacity(0.28)
                context.stroke(tickPath, with: .color(tickColor), lineWidth: isMajor ? 2.5 : 1.5)
            }

            // Pivot cap
            let capRadius: CGFloat = isPad ? 9 : 7
            context.fill(Path(ellipseIn: CGRect(x: pivot.x - capRadius, y: pivot.y - capRadius, width: capRadius * 2, height: capRadius * 2)), with: .color(.text))

            // Scale labels
            let flatPoint = point(angle: -sweepDegrees, radius: radius + (isPad ? 16 : 12))
            let sharpPoint = point(angle: sweepDegrees, radius: radius + (isPad ? 16 : 12))
            context.draw(Text("♭").font(.system(size: isPad ? 15 : 12, weight: .semibold)).foregroundColor(.textSecondary.opacity(0.7)), at: flatPoint)
            context.draw(Text("♯").font(.system(size: isPad ? 15 : 12, weight: .semibold)).foregroundColor(.textSecondary.opacity(0.7)), at: sharpPoint)
        }
    }

    // MARK: - Verdict
    private var verdictLabel: some View {
        Text(verdictText)
            .font(.system(size: 12, weight: .bold))
            .tracking(2)
            .foregroundColor(pointerColor)
            .animation(.easeOut(duration: 0.18), value: verdictText)
    }

    // MARK: - Helper State
    private var isInTune: Bool {
        guard let note = detectedNote else { return false }
        return abs(note.cents) <= CentsTolerance
    }

    private var pointerColor: Color {
        guard detectedNote != nil else { return Color.textSecondary.opacity(0.35) }
        return isInTune ? .success : .destructive
    }

    private var verdictText: String {
        guard let note = detectedNote else { return "LISTENING" }
        if isInTune { return "IN TUNE" }
        if note.cents > 0 {
            return showsStringGuidance ? "SHARP · LOOSEN" : "SHARP"
        }
        return showsStringGuidance ? "FLAT · TIGHTEN" : "FLAT"
    }
}

/// A needle shape pointing straight up from the bottom-center of its frame,
/// meant to be rotated with `.rotationEffect(_:anchor: .bottom)`.
private struct GaugeNeedle: Shape {
    func path(in rect: CGRect) -> Path {
        let baseWidth = rect.width
        let tipWidth: CGFloat = max(2, rect.width * 0.18)
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - baseWidth / 2, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - tipWidth / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + tipWidth / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + baseWidth / 2, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    Group {
        VStack(spacing: 20) {
            TunerCircleView(
                detectedNote: Note(name: "A", octave: 4, frequency: 440.0, cents: 5),
                isListening: .constant(true),
                useSharps: true
            )

            TunerCircleView(
                detectedNote: Note(name: "E", octave: 2, frequency: 83.0, cents: 22),
                isListening: .constant(true),
                useSharps: true,
                showsStringGuidance: true
            )

            TunerCircleView(
                detectedNote: nil,
                isListening: .constant(false),
                useSharps: true
            )
        }
        .padding()
        .background(Color.systemBackgroundColor)
        .preferredColorScheme(.light)
    }
}
