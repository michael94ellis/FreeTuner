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

    /// Analyze a PCM buffer and return dominant frequency + full spectrum
    func analyze(buffer: [Float]) -> (dominantFrequency: Float?, spectrum: [(frequency: Float, magnitude: Float)]) {
        guard buffer.count == fftSize else {
            print("Buffer size must match fftSize")
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

        // Compute magnitudes
        var magnitudes = [Float](repeating: 0, count: fftSize / 2)
        vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(fftSize / 2))

        // Convert to dB
        var zero: Float = 1e-10
        vDSP_vdbcon(magnitudes, 1, &zero, &magnitudes, 1, vDSP_Length(magnitudes.count), 0)

        // Map bins to frequencies
        let binFrequencies = (0..<magnitudes.count).map { i in
            Float(i) * sampleRate / Float(fftSize)
        }

        // Find the frequency range we're interested in
        let minBin = max(0, Int(minFrequency * Float(fftSize) / sampleRate))
        let maxBin = min(magnitudes.count - 1, Int(maxFrequency * Float(fftSize) / sampleRate))
        
        print("Frequency range: \(minFrequency)-\(maxFrequency) Hz, bins: \(minBin)-\(maxBin)")
        
        // Extract the relevant frequency range
        let relevantMagnitudes = Array(magnitudes[minBin...maxBin])
        let relevantFrequencies = Array(binFrequencies[minBin...maxBin])
        
        // Find the maximum magnitude in the relevant range
        guard let maxMagnitude = relevantMagnitudes.max(),
              let maxIndex = relevantMagnitudes.firstIndex(of: maxMagnitude) else {
            print("No valid magnitude found in relevant range")
            let spectrum = zip(binFrequencies, magnitudes).map { ($0, $1) }
            return (nil, spectrum)
        }
        
        let dominantFrequency = relevantFrequencies[maxIndex]
        
        print("Max magnitude: \(maxMagnitude) dB at \(dominantFrequency) Hz")
        
        // Apply noise threshold (only detect if magnitude is above a certain threshold)
        let noiseThreshold: Float = -60.0 // dB threshold
        if maxMagnitude > noiseThreshold {
            print("✅ Pitch detected: \(dominantFrequency) Hz (magnitude: \(maxMagnitude) dB)")
            let spectrum = zip(binFrequencies, magnitudes).map { ($0, $1) }
            return (dominantFrequency, spectrum)
        } else {
            print("❌ Below noise threshold: \(maxMagnitude) dB < \(noiseThreshold) dB")
            let spectrum = zip(binFrequencies, magnitudes).map { ($0, $1) }
            return (nil, spectrum)
        }
    }
}
