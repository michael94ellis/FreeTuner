//
//  PitchGraphView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/27/25.
//

import SwiftUI
import Charts

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
                        .font(isPad ? .title : .title2)
                        .foregroundColor(.primary)
                }
                
                if showingGraph {
                    averageFrequencyView
                        .id("avgfrq")
                } else {
                    averageFrequencyView
                        .hidden()
                        .frame(height: 0)
                        .id("avgfrq")
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingGraph.toggle()
                    }
                }) {
                    Image(systemName: showingGraph ? "chart.line.downtrend.xyaxis" : "chart.line.uptrend.xyaxis")
                        .font(isPad ? .title2 : .title3)
                        .foregroundColor(.blue)
                        .frame(width: isPad ? 65 : 44, height: isPad ? 65 : 44)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                .accessibilityLabel("Toggle pitch graph")
                .accessibilityValue(showingGraph ? "Expanded" : "Collapsed")
                .accessibilityHint("Shows or hides the pitch history graph")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingGraph.toggle()
                }
            }
            .padding(.horizontal, isPad ? 32 : 0)
            
            if showingGraph {
                // Graph content
                VStack(spacing: 12) {
                    if pitchData.isEmpty {
                        emptyStateView
                    } else {
                        chartView
                    }
                }
                .padding(.horizontal, isPad ? 32 : 0)
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
                .foregroundColor(.secondary)
            
            Text("No pitch data yet")
                .font(isPad ? .subheadline : .caption)
                .foregroundColor(.secondary)
            
            Text("Start listening to see pitch history")
                .font(isPad ? .caption : .caption2)
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(height: isPad ? 160 : 120)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
    
    @ViewBuilder
    private var chartView: some View {
        VStack(alignment: .leading, spacing: isPad ? 12 : 8) {
            Text("Frequency over Time")
                .font(isPad ? .subheadline : .caption)
                .foregroundColor(.secondary)
            
            Chart {
                ForEach(pitchData) { point in
                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Frequency", point.frequency)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Frequency", point.frequency)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .blue.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Pitch history graph")
            .accessibilityValue("\(pitchData.count) data points, average frequency \(Int(averageFrequency)) Hertz")
            .accessibilityHint("Shows frequency changes over time. Updates in real-time as new pitch data is collected.")
            .frame(height: isPad ? 180 : 120)
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.2))
                    AxisTick()
                        .foregroundStyle(.gray.opacity(0.5))
                    AxisValueLabel()
                        .font(isPad ? .caption : .caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.2))
                    AxisTick()
                        .foregroundStyle(.gray.opacity(0.5))
                    AxisValueLabel()
                        .font(isPad ? .caption : .caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .chartYScale(domain: frequencyRange)
        }
        .smallCardStyle(
            cornerRadius: 12,
            horizontalPadding: isPad ? 24 : 8,
            verticalPadding: isPad ? 24 : 12
        )
    }
    
    @ViewBuilder
    private var averageFrequencyView: some View {
        HStack(spacing: 16) {
            
            // Average frequency
            VStack(spacing: isPad ? 6 : 4) {
                Text("Average")
                    .font(isPad ? .title3 : .subheadline)
                    .foregroundColor(.secondary)
                    .frame(minWidth: 80, alignment: .trailing)
                            Text("\(Int(averageFrequency)) Hz")
                .font(isPad ? .title3 : .subheadline)
                .foregroundColor(.primary)
                .frame(minWidth: 80, alignment: .trailing)
                .accessibilityLabel("Average frequency")
                .accessibilityValue("\(Int(averageFrequency)) Hertz")
                .accessibilityHint("Average frequency over the recorded time period")
                .accessibilityAddTraits(.updatesFrequently)
            }
            .padding(.vertical, isPad ? 16 : 8)
            .padding(.horizontal, isPad ? 12 : 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
            .frame(maxWidth: .infinity)
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
    
    private var averageFrequency: Float {
        guard !pitchData.isEmpty else { return 0 }
        let sum = pitchData.reduce(0) { $0 + $1.frequency }
        return sum / Float(pitchData.count)
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
            return .green
        case "Good":
            return .blue
        case "Fair":
            return .orange
        case "Poor":
            return .red
        default:
            return .secondary
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
    .background(Color(.systemBackground))
}
