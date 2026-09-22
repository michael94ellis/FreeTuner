//
//  InstrumentSelectorView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 9/19/26.
//

import SwiftUI
import DesignSystem

/// A horizontal row of underlined tabs for switching between chromatic mode and instrument-specific tunings.
struct InstrumentSelectorView: View {
    @Binding var selectedInstrumentID: String
    @Environment(\.isPad) private var isPad

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: isPad ? 24 : 18) {
                ForEach(Instrument.all) { instrument in
                    instrumentTab(for: instrument)
                }
            }
        }
    }

    @ViewBuilder
    private func instrumentTab(for instrument: Instrument) -> some View {
        let isSelected = instrument.id == selectedInstrumentID

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedInstrumentID = instrument.id
            }
        } label: {
            Text(instrument.tabLabel)
                .font(isPad ? .headline : .subheadline.weight(.semibold))
                .foregroundColor(isSelected ? .text : .textSecondary.opacity(0.7))
                .padding(.bottom, 6)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(isSelected ? Color.success : Color.clear)
                        .frame(height: 2)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(instrument.name) tuning")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint(instrument.isChromatic ? "Detects any note" : "Shows target strings for \(instrument.name)")
    }
}

private extension Instrument {
    /// Short label for the tab bar — the drop tuning reads awkwardly at full length here.
    var tabLabel: String {
        id == "guitarDropD" ? "Drop D" : name
    }
}

#Preview {
    Group {
        InstrumentSelectorView(selectedInstrumentID: .constant(Instrument.chromatic.id))
            .padding()
            .background(Color.systemBackgroundColor)
            .preferredColorScheme(.light)

        InstrumentSelectorView(selectedInstrumentID: .constant(Instrument.guitarStandard.id))
            .padding()
            .background(Color.systemBackgroundColor)
            .preferredColorScheme(.dark)
    }
}
