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
    
    // Tooltip state
    @State private var showingTooltip = false
    
    // Collapsible state
    @State private var showingMeter = false
    
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
    
    var body: some View {
        
        VStack(spacing: 16) {
            // Header with collapsible button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Audio Level")
                        .font(.system(size: isPad ? 28 : 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Real-time volume monitoring")
                        .font(.system(size: isPad ? 22 : 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Info button
                Button(action: {
                    showingTooltip.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: isPad ? 18 : 14))
                        .foregroundColor(.blue)
                }
                .popover(isPresented: $showingTooltip) {
                    toolTipContent
                }
                
                Spacer()
                
                
                if showingMeter {
                    // Current decibel value
                    HStack {
                        Text("\(Int(decibels.rms))")
                            .font(.system(size: isPad ? 32 : 24, weight: .bold, design: .rounded))
                            .foregroundColor(meterColor)
                            .contentTransition(.numericText())
                        
                        Text("dB")
                            .font(.system(size: isPad ? 16 : 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, isPad ? 32 : 20)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }
                
                Spacer()
                
                // Collapsible button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingMeter.toggle()
                    }
                }) {
                    Image(systemName: showingMeter ? "thermometer.high" : "thermometer.medium.slash")
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
            
            
            if showingMeter {
                decibelMeter
            }
        }
    }
    
    var decibelMeter: some View {
        // Main horizontal bar meter
        VStack(spacing: isPad ? 12 : 8) {
            // Horizontal bar meter
            ZStack(alignment: .leading) {
                // Background bar
                RoundedRectangle(cornerRadius: isPad ? 12 : 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: isPad ? 24 : 18)
                
                // Progress bar
                RoundedRectangle(cornerRadius: isPad ? 12 : 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .yellow, .orange, .red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, normalizedLevel * (isPad ? 300 : 220)), height: isPad ? 24 : 18)
                    .animation(.easeInOut(duration: 0.1), value: normalizedLevel)
                
                // Peak indicator
                if peakDecibels > decibels.peak + 2 {
                    let peakNormalized = (max(minDb, min(maxDb, peakDecibels)) - minDb) / (maxDb - minDb)
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 3, height: isPad ? 28 : 22)
                        .offset(x: max(0, peakNormalized * (isPad ? 300 : 220) - 1.5))
                        .opacity(0.8)
                }
            }
            
            // Decibel scale markers
            HStack {
                Text("-60")
                    .font(.system(size: isPad ? 12 : 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("-40")
                    .font(.system(size: isPad ? 12 : 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("-20")
                    .font(.system(size: isPad ? 12 : 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("0")
                    .font(.system(size: isPad ? 12 : 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(width: isPad ? 300 : 220)
        }
        .padding(.horizontal, isPad ? 32 : 20)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
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
    
    var toolTipContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Decibel Range Explained")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("This tuner uses a digital audio scale called dBFS (decibels relative to full scale).")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("The color shows how loud the sound is overall, like an average, while the red line indicates the loudest detected frequency in the signal.")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text("0 dB is the loudest possible signal (clipping point)")
                    }
                    .font(.body)
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text("−60 dB is very quiet (near silence)")
                    }
                    .font(.body)
                }
                
                Text("Unlike sound pressure levels (SPL), which range from 0 to 140 dB in the physical world, digital audio works in a scale from −∞ to 0, where 0 is the maximum.")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("So if you see values like −45 dB or −30 dB, that's normal—it means your signal is active but not overpowering.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(isPad ? 20 : 8)
            .frame(maxWidth: isPad ? 500 : 300)
            .frame(height: isPad ? 400 : 400)
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
