//
//  PitchAnalyzer.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import Accelerate

class PitchAnalyzer {
    private let sampleRate: Float
    private let fftSize: Int
    private let log2n: vDSP_Length
    private let fftSetup: FFTSetup
    private var window: [Float]
    
    // Musical frequency range (A0 to C8)
    private let minFrequency: Float = 27.5  // A0
    private let maxFrequency: Float = 4186.0 // C8

    init(sampleRate: Float, fftSize: Int) {
        self.sampleRate = sampleRate
        self.fftSize = fftSize
        self.log2n = vDSP_Length(log2(Float(fftSize)))
        self.fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))!
        self.window = [Float](repeating: 0, count: fftSize)
        vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HANN_NORM))
    }

    deinit {
        vDSP_destroy_fftsetup(fftSetup)
    }
    
    /// Apply parabolic interpolation around the peak bin to estimate true frequency
    /// This improves frequency resolution beyond the FFT bin resolution
    private func parabolicInterpolation(
        magnitudes: [Float],
        frequencies: [Float],
        peakIndex: Int
    ) -> Float {
        let count = magnitudes.count
        
        // Need at least 3 points for interpolation
        guard count >= 3, peakIndex > 0, peakIndex < count - 1 else {
            return frequencies[peakIndex]
        }
        
        let y0 = magnitudes[peakIndex - 1]  // Left neighbor
        let y1 = magnitudes[peakIndex]      // Peak
        let y2 = magnitudes[peakIndex + 1]  // Right neighbor
        
        // Convert from dB back to linear scale for interpolation
        let linearY0 = pow(10.0, y0 / 20.0)
        let linearY1 = pow(10.0, y1 / 20.0)
        let linearY2 = pow(10.0, y2 / 20.0)
        
        // Parabolic interpolation formula
        // peak_offset = 0.5 * (y0 - y2) / (y0 - 2*y1 + y2)
        let numerator = linearY0 - linearY2
        let denominator = linearY0 - 2.0 * linearY1 + linearY2
        
        // Avoid division by zero
        guard abs(denominator) > 1e-10 else {
            return frequencies[peakIndex]
        }
        
        let peakOffset = 0.5 * numerator / denominator
        
        // Clamp the offset to prevent going out of bounds
        let clampedOffset = max(-0.5, min(0.5, peakOffset))
        
        // Calculate the interpolated frequency
        let binSpacing = frequencies[1] - frequencies[0]
        let interpolatedFrequency = frequencies[peakIndex] + clampedOffset * binSpacing
        
//        print("Interpolation: peak=\(frequencies[peakIndex])Hz, offset=\(clampedOffset), result=\(interpolatedFrequency)Hz")
        
        return interpolatedFrequency
    }

    /// Analyze a PCM buffer and return dominant frequency + full spectrum
    func analyze(buffer: [Float]) -> (dominantFrequency: Float?, spectrum: [FrequencyMagnitude]) {
        guard buffer.count == fftSize else {
            assertionFailure("Buffer size must match fftSize")
            return (nil, [])
        }

        // Apply window
        var windowedSignal = [Float](repeating: 0, count: fftSize)
        vDSP_vmul(buffer, 1, window, 1, &windowedSignal, 1, vDSP_Length(fftSize))

        // Convert to split complex format
        var realp = [Float](repeating: 0, count: fftSize / 2)
        var imagp = [Float](repeating: 0, count: fftSize / 2)
        var splitComplex = DSPSplitComplex(realp: &realp, imagp: &imagp)

        windowedSignal.withUnsafeBufferPointer { ptr in
            ptr.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: fftSize / 2) {
                vDSP_ctoz($0, 2, &splitComplex, 1, vDSP_Length(fftSize / 2))
            }
        }

        // Perform FFT
        vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))

        // Compute magnitudes (only need first half due to symmetry)
        var magnitudes = [Float](repeating: 0, count: fftSize / 2)
        vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(fftSize / 2))

        // Convert to dB
        var zero: Float = 1e-10
        vDSP_vdbcon(magnitudes, 1, &zero, &magnitudes, 1, vDSP_Length(magnitudes.count), 0)

        // Map bins to frequencies (corrected formula)
        // Bin 0 = DC (0 Hz), Bin N/2 = Nyquist frequency (sampleRate/2)
        let binFrequencies = (0..<magnitudes.count).map { i in
            Float(i) * sampleRate / Float(fftSize)
        }

        // Find the frequency range we're interested in
        let minBin = max(0, Int(minFrequency * Float(fftSize) / sampleRate))
        let maxBin = min(magnitudes.count - 1, Int(maxFrequency * Float(fftSize) / sampleRate))
        
//        print("Frequency range: \(minFrequency)-\(maxFrequency) Hz, bins: \(minBin)-\(maxBin)")
//        print("Sample rate: \(sampleRate) Hz, FFT size: \(fftSize), bin spacing: \(sampleRate / Float(fftSize)) Hz")
//        print("First few frequencies: \(Array(binFrequencies.prefix(10)))")
        
        // Extract the relevant frequency range
        let relevantMagnitudes = Array(magnitudes[minBin...maxBin])
        let relevantFrequencies = Array(binFrequencies[minBin...maxBin])
        
        // Find the maximum magnitude in the relevant range
        guard let maxMagnitude = relevantMagnitudes.max(),
              let maxIndex = relevantMagnitudes.firstIndex(of: maxMagnitude) else {
//            print("No valid magnitude found in relevant range")
            let spectrum = zip(binFrequencies, magnitudes).map { ($0, $1) }
                .compactMap { FrequencyMagnitude(frequency: $0.0, magnitude: $0.1) }
            
            return (nil, spectrum)
        }
        
        let rawFrequency = relevantFrequencies[maxIndex]
//        print("Raw peak: bin \(maxIndex + minBin) at \(rawFrequency) Hz (magnitude: \(maxMagnitude) dB)")
        
        // Apply parabolic interpolation around the peak bin for more accurate frequency estimation
        let interpolatedFrequency = parabolicInterpolation(
            magnitudes: relevantMagnitudes,
            frequencies: relevantFrequencies,
            peakIndex: maxIndex
        )
        
//        print("Max magnitude: \(maxMagnitude) dB at \(interpolatedFrequency) Hz (interpolated)")
//        
//        // Debug: Check if this looks like a reasonable frequency
//        if interpolatedFrequency > 0 && interpolatedFrequency < sampleRate / 2 {
//            print("✅ Frequency within valid range (0-\(sampleRate/2) Hz)")
//        } else {
//            print("❌ Frequency outside valid range: \(interpolatedFrequency) Hz")
//        }
        
        // Apply noise threshold (only detect if magnitude is above a certain threshold)
        let noiseThreshold: Float = -60.0 // dB threshold
        if maxMagnitude > noiseThreshold {
//            print("✅ Pitch detected: \(interpolatedFrequency) Hz (magnitude: \(maxMagnitude) dB)")
            let spectrum = zip(binFrequencies, magnitudes).map { ($0, $1) }
                .compactMap { FrequencyMagnitude(frequency: $0.0, magnitude: $0.1) }
            return (interpolatedFrequency, spectrum)
        } else {
//            print("❌ Below noise threshold: \(maxMagnitude) dB < \(noiseThreshold) dB")
            let spectrum = zip(binFrequencies, magnitudes).map { ($0, $1) }
                .compactMap { FrequencyMagnitude(frequency: $0.0, magnitude: $0.1) }
            return (nil, spectrum)
        }
    }
}
