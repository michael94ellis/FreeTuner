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
    @State private var peakDecibels: CGFloat = -100.0
    
    // Tooltip state
    @State private var showingTooltip = false
    
    // Collapsible state
    @State private var showingMeter = false
    
    // Decibel range for the meter
    private let minDb: CGFloat = -100.0
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
                Text("Signal Strength")
                    .font(isPad ? .title : .title2)
                    .foregroundColor(.primary)
                
                // Info button
                Button(action: {
                    showingTooltip.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .font(isPad ? .title2 : .title3)
                        .foregroundColor(.blue)
                }
                .popover(isPresented: $showingTooltip) {
                    toolTipContent
                }
                
                Spacer()
                
                
                // Current decibel value
                if showingMeter {
                    HStack {
                        Text(showingMeter ? "\(Int(decibels.rms))" : "  ")
                            .fixedSize()
                            .font(isPad ? .title : .title2)
                            .foregroundColor(meterColor)
                            .contentTransition(.numericText())
                        
                        Text(showingMeter ? "dB" : "  ")
                            .font(isPad ? .caption : .caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, isPad ? 16 : 8)
                    .padding(.horizontal, isPad ? 12 : 8)
                    .frame(minWidth: 80, alignment: .trailing)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6).opacity(0.5))
                    )
                    .frame(maxWidth: .infinity)
                    .id("decibelmeteravg")
                } else {
                    HStack {
                        Text("  ")
                            .fixedSize()
                            .font(isPad ? .title : .title2)
                            .contentTransition(.numericText())
                        Text("  ")
                            .font(isPad ? .caption : .caption2)
                    }
                    .id("decibelmeteravg")
                }
                
                
                Spacer()
                
                // Collapsible button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingMeter.toggle()
                    }
                }) {
                    Image(systemName: showingMeter ? "thermometer.high" : "thermometer.medium.slash")
                        .font(isPad ? .title2 : .title3)
                        .foregroundColor(.blue)
                        .frame(width: isPad ? 65 : 44, height: isPad ? 65 : 44)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingMeter.toggle()
                }
            }
            .padding(.horizontal, isPad ? 32 : 0)
            
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
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: isPad ? 12 : 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, meterColor]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, normalizedLevel * geo.size.width), height: isPad ? 24 : 18)
                        .animation(.easeInOut(duration: 0.1), value: normalizedLevel)
                }
                // Peak indicator
                let peakNormalized = (max(minDb, min(maxDb, peakDecibels)) - minDb) / (maxDb - minDb)
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 3, height: isPad ? 28 : 22)
                    .offset(x: max(0, peakNormalized * (isPad ? 300 : 220) - 1.5))
                    .opacity(0.8)
            }
            
            // Decibel scale markers
            HStack {
                Text("-100")
                    .font(isPad ? .caption : .caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("0")
                    .font(isPad ? .caption : .caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, isPad ? 32 : 0)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
        .largeCardStyle()
        .opacity(isListening ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: isListening)
        .onChange(of: decibels.peak) { _, _ in
            updatePeak()
        }
        .onChange(of: isListening) { _, listening in
            if !listening {
                peakDecibels = -100.0
            }
        }
    }
    
    var toolTipContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Decibel Range Explained")
                    .font(isPad ? .largeTitle : .title)
                    .foregroundColor(.primary)
                
                Text("This tuner uses a digital audio scale called dBFS, decibels relative to full scale.")
                    .font(isPad ? .body : .callout)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text("0 dB means the signal is at its maximum possible level (clipping)")
                    }
                    .font(isPad ? .headline : .subheadline)
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text("−60 dB is very quiet")
                    }
                    .font(isPad ? .headline : .subheadline)
                }
                
                Text("The colored bar shows the average loudness of the sound (RMS), while the thin red line marks the loudest moment detected (peak).")
                    .font(isPad ? .body : .callout)
                    .foregroundColor(.secondary)
                
                Text("Unlike the typically expected physical sound pressure levels (SPL), which range from 0 to 140 dB, digital audio uses a scale from −∞ to 0 dBFS, where 0 is the loudest possible value.")
                    .font(isPad ? .body : .callout)
                    .foregroundColor(.secondary)
                
                Text("So if you see values like −45 dB or −30 dB, that's normal, it means your signal is active but not overpowering.")
                    .font(isPad ? .body : .callout)
                    .foregroundColor(.secondary)
            }
            .padding(20)
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
