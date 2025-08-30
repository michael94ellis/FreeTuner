//
//  AudioLevelMeter.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/30/25.
//

import Accelerate

class AudioLevelMeter {
    private var smoothedDb: Float = -60.0
    private var smoothingFactor: Float = 0.1
    private var referenceLevel: Float = 1.0 // Full scale reference
    private let minDb: Float = -80.0
    private let maxDb: Float = 0.0

    /// Calculates smoothed RMS and peak decibel levels from audio samples
    /// RMS - Average Loudness
    /// Peak - Maximum volume of any micro-noise
    func calculateDecibelLevels(from samples: [Float]) -> (rms: Float, peak: Float) {
        guard !samples.isEmpty else {
            return (minDb, minDb)
        }

        // RMS Calculation
        var rms: Float = 0.0
        vDSP_rmsqv(samples, 1, &rms, vDSP_Length(samples.count))
        let rawRmsDb = 20 * log10(max(rms / referenceLevel, 1e-10))

        // Peak Calculation
        let peak = samples.map { abs($0) }.max() ?? 0.0
        let rawPeakDb = 20 * log10(max(peak / referenceLevel, 1e-10))

        // Smoothing
        smoothedDb = (1.0 - smoothingFactor) * smoothedDb + smoothingFactor * rawRmsDb

        // Clamping
        let clampedRmsDb = max(minDb, min(maxDb, smoothedDb))
        let clampedPeakDb = max(minDb, min(maxDb, rawPeakDb))

        return (clampedRmsDb, clampedPeakDb)
    }
}
