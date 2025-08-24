//
//  PitchTapManager.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import AVFoundation

class PitchTapManager {
    private let engine = AVAudioEngine()
    private var analyzer: PitchAnalyzer?
    private var fftSize: Int = 1024  // Default, will be adjusted based on actual buffer size
    private var inputFormat: AVAudioFormat?
    private let queue = DispatchQueue(label: "PitchTapQueue")

    var onPitchDetected: ((Float, [(frequency: Float, magnitude: Float)]) -> Void)?

    init() {
        // fftSize will be set dynamically based on the actual buffer size
    }

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
            print("Audio format not initialized")
            return
        }
        
        print("Installing tap with format: sampleRate=\(format.sampleRate), channels=\(format.channelCount)")
        
        // Request a reasonable buffer size, but be prepared to adapt
        let requestedBufferSize = AVAudioFrameCount(1024)
        
        engine.inputNode.installTap(onBus: 0,
                                    bufferSize: requestedBufferSize,
                                    format: format) { [weak self] buffer, _ in
            guard let self = self else { return }

            self.queue.async {
                print("tap queue - buffer frameLength: \(buffer.frameLength)")
                guard let channelData = buffer.floatChannelData?[0] else { 
                    print("No channel data available")
                    return 
                }
                let frameLength = Int(buffer.frameLength)

                // Adapt FFT size to match the actual buffer size
                if self.fftSize != frameLength {
                    print("Adjusting FFT size from \(self.fftSize) to \(frameLength)")
                    self.fftSize = frameLength
                    
                    // Reinitialize analyzer with new FFT size
                    self.analyzer = PitchAnalyzer(sampleRate: Float(format.sampleRate), fftSize: frameLength)
                }

                // Copy samples into array
                let samples = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
                print("Processing \(samples.count) samples with FFT size \(self.fftSize)")

                guard let analyzer = self.analyzer else {
                    print("Analyzer not initialized")
                    return
                }

                let result = analyzer.analyze(buffer: samples)
                print("Analysis result - dominant frequency: \(result.dominantFrequency ?? 0)")
                
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
