//
//  PitchPlayer.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import AVFoundation
import Foundation

enum WaveformType: String, CaseIterable {
    case sine = "Sine"
    case square = "Square"
    case triangle = "Triangle"
    case sawtooth = "Sawtooth"
}

class PitchPlayer: ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var audioFormat: AVAudioFormat?
    private var isPlaying = false
    private var currentFrequency: Float = 440.0
    private var isContinuousPlayback = false
    
    @Published var isCurrentlyPlaying = false
    @Published var selectedWaveform: WaveformType = .sine
    
    init() {
        setupAudioEngine()
    }
    
    deinit {
        stop()
    }
    
    private func setupAudioEngine() {
        // Configure audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        
        guard let engine = audioEngine,
              let player = playerNode else {
            print("Failed to create audio engine or player node")
            return
        }
        
        // Create audio format for output
        audioFormat = AVAudioFormat(
            standardFormatWithSampleRate: 44100,
            channels: 1
        )
        
        guard let format = audioFormat else {
            print("Failed to create audio format")
            return
        }
        
        // Attach player node to engine
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func play(frequency: Float, duration: TimeInterval? = nil) {
        guard let player = playerNode,
              let format = audioFormat else {
            return
        }
        
        // Stop any currently playing tone
        stop()
        
        currentFrequency = frequency
        isContinuousPlayback = (duration == nil)
        
        if let duration = duration {
            // Play for specified duration
            let buffer = generateWaveform(frequency: frequency, duration: duration, format: format, waveform: selectedWaveform)
            
            player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: { [weak self] in
                DispatchQueue.main.async {
                    self?.isPlaying = false
                    self?.isCurrentlyPlaying = false
                }
            })
        } else {
            // Play continuously
            scheduleContinuousPlayback(frequency: frequency, format: format)
        }
        
        // Start playback
        player.play()
        
        isPlaying = true
        isCurrentlyPlaying = true
    }
    
    func stop() {
        guard let player = playerNode else { return }
        
        player.stop()
        player.reset()
        isPlaying = false
        isCurrentlyPlaying = false
        isContinuousPlayback = false
    }
    
    func changeFrequency(to newFrequency: Float) {
        guard isPlaying && isContinuousPlayback,
              let player = playerNode,
              let format = audioFormat else {
            return
        }
        
        currentFrequency = newFrequency
        
        // Stop current playback and restart with new frequency
        player.stop()
        scheduleContinuousPlayback(frequency: newFrequency, format: format)
        player.play()
    }
    
    func changeWaveform(to newWaveform: WaveformType) {
        guard isPlaying && isContinuousPlayback,
              let player = playerNode,
              let format = audioFormat else {
            return
        }
        
        selectedWaveform = newWaveform
        
        // Stop current playback and restart with new waveform
        player.stop()
        scheduleContinuousPlayback(frequency: currentFrequency, format: format)
        player.play()
    }
    
    private func scheduleContinuousPlayback(frequency: Float, format: AVAudioFormat) {
        guard let player = playerNode else { return }
        
        // Clear any existing buffers
        player.reset()
        
        // Create a buffer that's long enough to avoid gaps but not too long to cause memory issues
        let bufferDuration: TimeInterval = 1.0 // 1 second buffer
        let buffer = generateWaveform(frequency: frequency, duration: bufferDuration, format: format, waveform: selectedWaveform)
        
        // Schedule the buffer with looping
        player.scheduleBuffer(buffer, at: nil, options: [.loops], completionHandler: nil)
    }
    
    private func generateWaveform(frequency: Float, duration: TimeInterval, format: AVAudioFormat, waveform: WaveformType) -> AVAudioPCMBuffer {
        let sampleRate = Float(format.sampleRate)
        let frameCount = AVAudioFrameCount(sampleRate * Float(duration))
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            fatalError("Failed to create audio buffer")
        }
        
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData?[0] else {
            fatalError("Failed to get channel data")
        }
        
        // Generate waveform samples
        let amplitude: Float = 0.3 // Reduced amplitude to prevent clipping
        let angularFrequency = 2.0 * Float.pi * frequency
        
        for frame in 0..<Int(frameCount) {
            let time = Float(frame) / sampleRate
            let phase = angularFrequency * time
            let sample = amplitude * generateSample(phase: phase, waveform: waveform)
            channelData[frame] = sample
        }
        
        return buffer
    }
    
    private func generateSample(phase: Float, waveform: WaveformType) -> Float {
        switch waveform {
        case .sine:
            return sin(phase)
        case .square:
            return sin(phase) >= 0 ? 1.0 : -1.0
        case .triangle:
            let normalizedPhase = (phase / (2.0 * Float.pi)).truncatingRemainder(dividingBy: 1.0)
            if normalizedPhase < 0.5 {
                return 2.0 * normalizedPhase - 1.0
            } else {
                return 1.0 - 2.0 * (normalizedPhase - 0.5)
            }
        case .sawtooth:
            let normalizedPhase = (phase / (2.0 * Float.pi)).truncatingRemainder(dividingBy: 1.0)
            return 2.0 * normalizedPhase - 1.0
        }
    }
}
