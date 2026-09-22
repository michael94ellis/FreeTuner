//
//  PitchGraphView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/27/25.
//

import SwiftUI
import Charts
import DesignSystem

struct PitchDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let frequency: Float
}

struct PitchGraphView: View {
    let pitchData: [PitchDataPoint]
    let isListening: Bool
    @Environment(\.isPad) private var isPad
    let maxDataPoints: Int // Maximum number of data points to display in the graph
    
    @State private var showingGraph = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pitch History")
                        .font(.system(size: isPad ? 18 : 15, weight: .semibold))
                        .foregroundColor(.text)
                }
                
                Spacer()
                if showingGraph {
                    AverageFrequencyLabel(pitchData: pitchData)
                        .id("avgfrq")
                } else {
                    AverageFrequencyLabel(pitchData: [])
                        .hidden()
                        .frame(height: 0)
                        .id("avgfrq")
                }
                
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingGraph.toggle()
                    }
                }) {
                    Image(systemName: showingGraph ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textSecondary.opacity(0.6))
                }
                .accessibilityLabel("Toggle pitch graph")
                .accessibilityValue(showingGraph ? "Expanded" : "Collapsed")
                .accessibilityHint("Shows or hides the pitch history graph")
            }
            .padding(.top, 16)
            .overlay(alignment: .top) {
                Rectangle().fill(Color.text.opacity(0.10)).frame(height: 1)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingGraph.toggle()
                }
            }
            
            if showingGraph {
                // Graph content
                VStack(spacing: 12) {
                    if pitchData.isEmpty {
                        emptyStateView
                    } else {
                        chartView
                    }
                }
                .padding(.top, 12)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: isPad ? 16 : 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(isPad ? .title : .title2)
                .foregroundColor(.textSecondary)

            Text("No pitch data yet")
                .font(isPad ? .subheadline : .caption)
                .foregroundColor(.textSecondary)

            Text("Start listening to see pitch history")
                .font(isPad ? .caption : .caption2)
                .foregroundColor(.textSecondary.opacity(0.8))
        }
        .frame(height: isPad ? 160 : 120)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.backgroundElevated.opacity(0.5))
        )
    }
    
    @ViewBuilder
    private var chartView: some View {
        VStack(alignment: .leading, spacing: isPad ? 12 : 8) {
            Text("Frequency over Time")
                .font(isPad ? .subheadline : .caption)
                .foregroundColor(.textSecondary)

            Chart {
                ForEach(pitchData) { point in
                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Frequency", point.frequency)
                    )
                    .foregroundStyle(Color.accent)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    AreaMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Frequency", point.frequency)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accent.opacity(0.3), Color.accent.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Pitch history graph")
            .accessibilityValue("Data graph for average frequency in Hertz")
            .accessibilityHint("Shows frequency changes over time. Updates in real-time as new pitch data is collected.")
            .frame(height: isPad ? 180 : 120)
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color.textSecondary.opacity(0.2))
                    AxisTick()
                        .foregroundStyle(Color.textSecondary.opacity(0.5))
                    AxisValueLabel()
                        .font(isPad ? .caption : .caption2)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color.textSecondary.opacity(0.2))
                    AxisTick()
                        .foregroundStyle(Color.textSecondary.opacity(0.5))
                    AxisValueLabel()
                        .font(isPad ? .caption : .caption2)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .chartYScale(domain: frequencyRange)
        }
    }
    
    // MARK: - Computed Properties
    
    private var frequencyRange: ClosedRange<Float> {
        guard !pitchData.isEmpty else { return 0...1000 }
        
        let frequencies = pitchData.map { $0.frequency }
        let minFreq = frequencies.min() ?? 0
        let maxFreq = frequencies.max() ?? 1000
        let range = maxFreq - minFreq
        
        // Add some padding to the range
        let padding = range * 0.1
        return (minFreq - padding)...(maxFreq + padding)
    }
    
    private var stabilityText: String {
        guard pitchData.count > 1 else { return "N/A" }
        
        let frequencies = pitchData.map { $0.frequency }
        let mean = frequencies.reduce(0, +) / Float(frequencies.count)
        let variance = frequencies.reduce(0) { $0 + pow($1 - mean, 2) } / Float(frequencies.count)
        let standardDeviation = sqrt(variance)
        
        // Convert to cents for more meaningful stability measure
        let centsDeviation = 1200 * log2(1 + standardDeviation / mean)
        
        if centsDeviation < 5 {
            return "Excellent"
        } else if centsDeviation < 15 {
            return "Good"
        } else if centsDeviation < 30 {
            return "Fair"
        } else {
            return "Poor"
        }
    }
    
    private var stabilityColor: Color {
        switch stabilityText {
        case "Excellent":
            return .success
        case "Good":
            return .accent
        case "Fair":
            return .warning
        case "Poor":
            return .destructive
        default:
            return .textSecondary
        }
    }
}

#Preview {
    VStack {
        // Empty state
        PitchGraphView(pitchData: [], isListening: false, maxDataPoints: 100)
        
        // With data
        let sampleData = [
            PitchDataPoint(timestamp: Date().addingTimeInterval(-10), frequency: 440),
            PitchDataPoint(timestamp: Date().addingTimeInterval(-8), frequency: 441),
            PitchDataPoint(timestamp: Date().addingTimeInterval(-6), frequency: 439),
            PitchDataPoint(timestamp: Date().addingTimeInterval(-4), frequency: 440),
            PitchDataPoint(timestamp: Date().addingTimeInterval(-2), frequency: 442),
            PitchDataPoint(timestamp: Date(), frequency: 440)
        ]
        
        PitchGraphView(pitchData: sampleData, isListening: true, maxDataPoints: 100)
    }
    .padding()
    .background(Color.systemBackgroundColor)
}
