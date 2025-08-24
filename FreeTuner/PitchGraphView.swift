//
//  PitchGraphView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct PitchGraphView: View {
    let spectrum: [(frequency: Float, magnitude: Float)]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard !spectrum.isEmpty else { return }
                
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Find max magnitude for scaling
                let maxMagnitude = spectrum.map { $0.magnitude }.max() ?? 1.0
                
                // Start path
                let firstPoint = CGPoint(
                    x: 0,
                    y: height - (CGFloat(spectrum[0].magnitude / maxMagnitude) * height)
                )
                path.move(to: firstPoint)
                
                // Draw spectrum line
                for (index, point) in spectrum.enumerated() {
                    let x = CGFloat(index) / CGFloat(spectrum.count - 1) * width
                    let y = height - (CGFloat(point.magnitude / maxMagnitude) * height)
                    
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.green, lineWidth: 2)
            .background(Color.black.opacity(0.1))
        }
        .frame(height: 200)
        .background(Color.black.opacity(0.05))
        .cornerRadius(8)
    }
}

struct FrequencyLabelsView: View {
    let spectrum: [(frequency: Float, magnitude: Float)]
    
    var body: some View {
        HStack {
            if let minFreq = spectrum.first?.frequency {
                Text("\(Int(minFreq)) Hz")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let maxFreq = spectrum.last?.frequency {
                Text("\(Int(maxFreq)) Hz")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack {
        PitchGraphView(spectrum: [
            (frequency: 100, magnitude: 0.1),
            (frequency: 200, magnitude: 0.3),
            (frequency: 300, magnitude: 0.8),
            (frequency: 400, magnitude: 0.5),
            (frequency: 500, magnitude: 0.2)
        ])
        FrequencyLabelsView(spectrum: [
            (frequency: 100, magnitude: 0.1),
            (frequency: 200, magnitude: 0.3),
            (frequency: 300, magnitude: 0.8),
            (frequency: 400, magnitude: 0.5),
            (frequency: 500, magnitude: 0.2)
        ])
    }
    .padding()
}
