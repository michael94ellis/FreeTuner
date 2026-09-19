//
//  ProUpsellView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 9/19/26.
//

import SwiftUI
import DesignSystem

/// Monetization-agnostic upsell sheet: no price or plan is shown since the
/// purchase model (subscription vs. one-time unlock) hasn't been decided yet.
struct ProUpsellView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPad) private var isPad

    private let features: [(number: String, title: String, subtitle: String)] = [
        ("01", "Note Recorder", "Capture every note, octave & timing as you play, then review the full timeline."),
        ("02", "Extended Pitch History", "Unlimited trail instead of the last few hundred points."),
        ("03", "More Instrument Tunings", "Open tunings, banjo, mandolin, and custom presets."),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                Text("TUNER GAUGE PRO")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.6)
                    .foregroundColor(.textSecondary.opacity(0.7))

                Text("Keep what you played")
                    .font(.system(size: isPad ? 34 : 28, weight: .bold))
                    .foregroundColor(.text)
                    .padding(.top, 2)

                Text("The tuner stays free. Pro adds the record and review layer on top of it.")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .padding(.top, 8)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 0) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        featureRow(feature)
                            .padding(.top, 16)
                            .padding(.bottom, 16)
                            .overlay(alignment: .top) {
                                if index > 0 {
                                    Rectangle().fill(Color.text.opacity(0.08)).frame(height: 1)
                                }
                            }
                    }
                }
                .padding(.top, 24)

                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accent, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.top, 24)

                Text("Plan & pricing shown at checkout")
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)

                Button("Maybe Later") {
                    dismiss()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .background(Color.systemBackgroundColor)
    }

    private func featureRow(_ feature: (number: String, title: String, subtitle: String)) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(feature.number)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.textSecondary.opacity(0.6))
                .padding(.top, 3)
                .frame(width: 18, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(feature.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.text)
                Text(feature.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    Group {
        ProUpsellView()
            .preferredColorScheme(.light)
        ProUpsellView()
            .preferredColorScheme(.dark)
    }
}
