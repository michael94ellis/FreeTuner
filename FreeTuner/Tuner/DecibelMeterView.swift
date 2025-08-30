//
//  DecibelMeterView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/27/25.
//

import SwiftUI

struct DecibelMeterView: View {
    let decibels: (rms: CGFloat, peak: CGFloat)
    let isListening: Bool
    
    // Device-specific sizing
    @Environment(\.isPad) private var isPad
    
    // Peak tracking
    @State private var peakDecibels: CGFloat = -60.0
    
    // Decibel range for the meter
    private let minDb: CGFloat = -60.0
    private let maxDb: CGFloat = 0.0
    
    // Normalize decibels to 0-1 range for the meter
    private var normalizedLevel: CGFloat {
        let clamped = max(minDb, min(maxDb, decibels.rms))
        return (clamped - minDb) / (maxDb - minDb)
    }
    
    // Update peak when decibels change
    private func updatePeak() {
        if decibels.peak > peakDecibels {
            peakDecibels = decibels.peak
        } else {
            // Gradually decay the peak
            peakDecibels = max(peakDecibels - 0.5, decibels.peak)
        }
    }
    
    // Color based on decibel level
    private var meterColor: Color {
        if decibels.rms < -40 {
            return .green
        } else if decibels.rms < -20 {
            return .yellow
        } else if decibels.rms < -10 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Animated color for the needle
    private var needleColor: Color {
        if decibels.rms < -40 {
            return .green
        } else if decibels.rms < -20 {
            return .yellow
        } else if decibels.rms < -10 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: isPad ? 16 : 12) {
            // Title
            Text("Volume Level")
                .font(.system(size: isPad ? 20 : 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            // Main meter display
            ZStack {
                meterContent
            }
            
            // Level indicator bars
            HStack(spacing: isPad ? 8 : 4) {
                ForEach(0..<10, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor(for: index))
                        .frame(width: isPad ? 8 : 6, height: isPad ? 40 : 30)
                        .scaleEffect(y: barScale(for: index), anchor: .bottom)
                        .animation(.easeInOut(duration: 0.1), value: normalizedLevel)
                }
            }
            .padding(.top, isPad ? 8 : 4)
        }
        .padding(.horizontal, isPad ? 24 : 16)
        .padding(.vertical, isPad ? 20 : 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .opacity(isListening ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: isListening)
        .onChange(of: decibels.peak) { _, _ in
            updatePeak()
        }
        .onChange(of: isListening) { _, listening in
            if !listening {
                peakDecibels = -60.0
            }
        }
    }
    
    @ViewBuilder
    var meterContent: some View {
        // Background circle
        Circle()
            .stroke(Color.gray.opacity(0.2), lineWidth: isPad ? 8 : 6)
            .frame(width: isPad ? 200 : 140, height: isPad ? 200 : 140)
        
        // Meter arc
        Circle()
            .trim(from: 0, to: 0.75) // 270 degrees
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [.green, .yellow, .orange, .red]),
                    center: .center,
                    startAngle: .degrees(-135),
                    endAngle: .degrees(135)
                ),
                style: StrokeStyle(lineWidth: isPad ? 8 : 6, lineCap: .round)
            )
            .frame(width: isPad ? 200 : 140, height: isPad ? 200 : 140)
            .rotationEffect(.degrees(-135))
        
        // Needle
        Rectangle()
            .fill(needleColor)
            .frame(width: isPad ? 4 : 3, height: isPad ? 80 : 60)
            .offset(y: isPad ? -40 : -30)
            .rotationEffect(.degrees(Double(normalizedLevel) * 270 - 135))
            .animation(.easeInOut(duration: 0.1), value: normalizedLevel)
            .shadow(color: needleColor.opacity(0.5), radius: 2, x: 0, y: 1)
        
        // Center dot
        Circle()
            .fill(needleColor)
            .frame(width: isPad ? 12 : 8, height: isPad ? 12 : 8)
            .shadow(color: needleColor.opacity(0.3), radius: 1, x: 0, y: 1)
        
        // Peak indicator
        if peakDecibels > decibels.peak + 2 {
            let peakNormalized = (max(minDb, min(maxDb, peakDecibels)) - minDb) / (maxDb - minDb)
            Rectangle()
                .fill(Color.red)
                .frame(width: isPad ? 6 : 4, height: isPad ? 4 : 3)
                .offset(y: isPad ? -40 : -30)
                .rotationEffect(.degrees(Double(peakNormalized) * 270 - 135))
                .opacity(0.8)
        }
        
        // Decibel value
        VStack(spacing: 4) {
            Text("\(Int(decibels.rms))")
                .font(.system(size: isPad ? 32 : 24, weight: .bold, design: .rounded))
                .foregroundColor(needleColor)
                .contentTransition(.numericText())
            
            Text("dB")
                .font(.system(size: isPad ? 16 : 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .offset(y: isPad ? 60 : 45)
    }
    
    private func barColor(for index: Int) -> Color {
        let threshold = CGFloat(index) / 10.0
        if normalizedLevel >= threshold {
            return meterColor
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private func barScale(for index: Int) -> CGFloat {
        let threshold = CGFloat(index) / 10.0
        if normalizedLevel >= threshold {
            return 1.0
        } else {
            return 0.3
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DecibelMeterView(decibels: (-30, -30), isListening: true)
        DecibelMeterView(decibels: (-15, -15), isListening: true)
        DecibelMeterView(decibels: (-5, -5), isListening: false)
    }
    .padding()
}
