//
//  AudioInputManager.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import AVFoundation

class AudioInputManager {
    private let engine = AVAudioEngine()
    private var analyzer: PitchAnalyzer?
    private var fftSize: Int = 2048
    private var inputFormat: AVAudioFormat?
    private let queue = DispatchQueue(label: "PitchTapQueue")

    var onPitchDetected: ((Float, [(frequency: Float, magnitude: Float)]) -> Void)?

    func start() throws {
        // Configure audio session first
        try configureAudioSession()
        
        // Get input format after session is configured
        let inputNode = engine.inputNode
        self.inputFormat = inputNode.inputFormat(forBus: 0)
        
        // Validate the format
        guard let format = inputFormat,
              format.sampleRate > 0,
              format.channelCount > 0 else {
            throw NSError(domain: "PitchTapManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid audio format"])
        }
        
        // Initialize analyzer with valid sample rate
        self.analyzer = PitchAnalyzer(sampleRate: Float(format.sampleRate), fftSize: fftSize)
        
        installTap()
        try engine.start()
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
    }
    
    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        
        // Request microphone permission
        audioSession.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if !granted {
                    print("Microphone permission denied")
                }
            }
        }
        
        // Configure audio session
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession.setActive(true)
    }

    private func installTap() {
        guard let format = inputFormat else {
            assertionFailure("Audio format not initialized")
            return
        }
        
        
        // Request a buffer size that matches our FFT size for consistency
        let requestedBufferSize = AVAudioFrameCount(fftSize)
        
        engine.inputNode.installTap(onBus: 0,
                                    bufferSize: requestedBufferSize,
                                    format: format) { [weak self] buffer, _ in
            guard let self = self else { return }

            self.queue.async {
                guard let channelData = buffer.floatChannelData?[0] else {
                    assertionFailure("No channel data available")
                    return
                }
                let frameLength = Int(buffer.frameLength)

                // Handle buffer size mismatch by processing in chunks
                if frameLength != self.fftSize {
                    
                    // Process the buffer in chunks of fftSize
                    let numChunks = frameLength / self.fftSize
                    for chunk in 0..<numChunks {
                        let startIndex = chunk * self.fftSize
                        
                        // Extract chunk of samples
                        let chunkSamples = Array(UnsafeBufferPointer(
                            start: channelData.advanced(by: startIndex),
                            count: self.fftSize
                        ))
                        
                        
                        guard let analyzer = self.analyzer else {
                            assertionFailure("Analyzer not initialized")
                            return
                        }

                        let result = analyzer.analyze(buffer: chunkSamples)
                        // Call the callback with the first chunk that has a valid pitch
                        if let pitch = result.dominantFrequency {
                            self.onPitchDetected?(pitch, result.spectrum)
                            return // Use the first valid pitch found
                        }
                    }
                    
                    // If no valid pitch found in any chunk, call with 0
                    self.onPitchDetected?(0, [])
                    return
                }

                // Copy samples into array (when buffer size matches FFT size)
                let samples = Array(UnsafeBufferPointer(start: channelData, count: frameLength))

                guard let analyzer = self.analyzer else {
                    assertionFailure("Analyzer not initialized")
                    return
                }

                let result = analyzer.analyze(buffer: samples)
                
                // Always call the callback with spectrum data, even if no dominant pitch
                if let pitch = result.dominantFrequency {
                    self.onPitchDetected?(pitch, result.spectrum)
                } else {
                    // Call with 0 pitch but still provide spectrum for visualization
                    self.onPitchDetected?(0, result.spectrum)
                }
            }
        }
    }
}
