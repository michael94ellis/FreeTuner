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
    let isPad: Bool
    let maxDataPoints: Int = 100 // Keep last 100 data points
    
    @State private var showingGraph = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pitch History")
                        .font(.system(size: isPad ? 28 : 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Real-time frequency tracking")
                        .font(.system(size: isPad ? 22 : 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingGraph.toggle()
                    }
                }) {
                    Image(systemName: showingGraph ? "chart.line.downtrend.xyaxis" : "chart.line.uptrend.xyaxis")
                        .font(.system(size: isPad ? 32 : 18, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(width: isPad ? 65 : 44, height: isPad ? 65 : 44)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, isPad ? 32 : 20)
            
            if showingGraph {
                // Graph content
                VStack(spacing: 12) {
                    if pitchData.isEmpty {
                        emptyStateView
                    } else {
                        chartView
                        statsView
                    }
                }
                .padding(.horizontal, isPad ? 32 : 20)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: isPad ? 16 : 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: isPad ? 48 : 32, weight: .light))
                .foregroundColor(.secondary)
            
            Text("No pitch data yet")
                .font(.system(size: isPad ? 24 : 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("Start listening to see pitch history")
                .font(.system(size: isPad ? 20 : 12, weight: .regular))
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
                .font(.system(size: isPad ? 20 : 14, weight: .medium))
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
            .frame(height: isPad ? 180 : 120)
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.2))
                    AxisTick()
                        .foregroundStyle(.gray.opacity(0.5))
                    AxisValueLabel()
                        .font(.system(size: isPad ? 18 : 13, weight: .medium))
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
                        .font(.system(size: isPad ? 18 : 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .chartYScale(domain: frequencyRange)
        }
        .padding(isPad ? 24 : 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var statsView: some View {
        HStack(spacing: 16) {
            // Current frequency
            VStack(spacing: 4) {
                Text("Current")
                    .font(.system(size: isPad ? 20 : 14, weight: .medium))
                    .foregroundColor(.secondary)
                Text("\(Int(pitchData.last?.frequency ?? 0)) Hz")
                    .font(.system(size: isPad ? 20 : 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, isPad ? 12 : 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
            
            // Average frequency
            VStack(spacing: isPad ? 6 : 4) {
                Text("Average")
                    .font(.system(size: isPad ? 20 : 14, weight: .medium))
                    .foregroundColor(.secondary)
                Text("\(Int(averageFrequency)) Hz")
                    .font(.system(size: isPad ? 22 : 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, isPad ? 12 : 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
            
            // Stability indicator
            VStack(spacing: isPad ? 6 : 4) {
                Text("Stability")
                    .font(.system(size: isPad ? 20 : 14, weight: .medium))
                    .foregroundColor(.secondary)
                Text(stabilityText)
                    .font(.system(size: isPad ? 20 : 14, weight: .semibold))
                    .foregroundColor(stabilityColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, isPad ? 12 : 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
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
        PitchGraphView(pitchData: [], isListening: false, isPad: true)
        
        // With data
        let sampleData = [
            PitchDataPoint(timestamp: Date().addingTimeInterval(-10), frequency: 440),
            PitchDataPoint(timestamp: Date().addingTimeInterval(-8), frequency: 441),
            PitchDataPoint(timestamp: Date().addingTimeInterval(-6), frequency: 439),
            PitchDataPoint(timestamp: Date().addingTimeInterval(-4), frequency: 440),
            PitchDataPoint(timestamp: Date().addingTimeInterval(-2), frequency: 442),
            PitchDataPoint(timestamp: Date(), frequency: 440)
        ]
        
        PitchGraphView(pitchData: sampleData, isListening: true, isPad: false)
    }
    .padding()
    .background(Color(.systemBackground))
}
