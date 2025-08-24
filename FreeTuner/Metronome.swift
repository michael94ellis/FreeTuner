//
//  Metronome.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import AVFoundation
import Foundation

class Metronome: ObservableObject {
    private var audioEngine: AVAudioEngine
    private var clickPlayer: AVAudioPlayerNode
    private var timer: Timer?
    
    @Published var isPlaying = false
    @Published var bpm: Int = 120
    @Published var timeSignature: TimeSignature = .fourFour
    @Published var currentBeat: Int = 0
    @Published var accentedBeats: Set<Int> = [0] // Beat 0 (first beat) is accented by default
    
    // Audio buffers for click sounds
    private var normalClickBuffer: AVAudioPCMBuffer?
    private var accentedClickBuffer: AVAudioPCMBuffer?
    
    struct TimeSignature {
        let beats: Int
        let noteValue: Int
        let name: String
        
        static let twoTwo = TimeSignature(beats: 2, noteValue: 2, name: "2/2 (Cut Time)")
        static let twoFour = TimeSignature(beats: 2, noteValue: 4, name: "2/4")
        static let threeFour = TimeSignature(beats: 3, noteValue: 4, name: "3/4")
        static let fourFour = TimeSignature(beats: 4, noteValue: 4, name: "4/4 (Common Time)")
        static let fiveFour = TimeSignature(beats: 5, noteValue: 4, name: "5/4")
        static let sixFour = TimeSignature(beats: 6, noteValue: 4, name: "6/4")
        static let threeEight = TimeSignature(beats: 3, noteValue: 8, name: "3/8")
        static let sixEight = TimeSignature(beats: 6, noteValue: 8, name: "6/8")
        static let nineEight = TimeSignature(beats: 9, noteValue: 8, name: "9/8")
        static let twelveEight = TimeSignature(beats: 12, noteValue: 8, name: "12/8")
        
        static var allValues: [TimeSignature] = [.twoTwo,
                                                 .twoFour,
                                                 .threeFour,
                                                 .fourFour,
                                                 .fiveFour,
                                                 .sixFour,
                                                 .threeEight,
                                                 .sixEight,
                                                 .nineEight,
                                                 .twelveEight]
    }
    
    init() {
        audioEngine = AVAudioEngine()
        clickPlayer = AVAudioPlayerNode()
        
        setupAudioEngine()
        setupAudioSessionNotifications()
    }
    
    private func setupAudioEngine() {
        // Configure audio session first
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        
        audioEngine.attach(clickPlayer)
        
        // Get the main mixer node's format to ensure compatibility
        let mainMixerFormat = audioEngine.mainMixerNode.outputFormat(forBus: 0)
        audioEngine.connect(clickPlayer, to: audioEngine.mainMixerNode, format: mainMixerFormat)
        
        do {
            try audioEngine.start()
            // Generate click sound after audio engine is started and format is available
            generateClickSound()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func generateClickSound() {
        // Use the same format as the audio engine
        let mainMixerFormat = audioEngine.mainMixerNode.outputFormat(forBus: 0)
        let sampleRate = mainMixerFormat.sampleRate
        let channelCount = mainMixerFormat.channelCount
        
        print("Generating click sounds: sampleRate=\(sampleRate), channels=\(channelCount)")
        
        let duration: Double = 0.1 // 100ms click
        let normalFrequency: Double = 800 // Hz for normal click
        let accentedFrequency: Double = 1000 // Hz for accented click (higher pitch)
        
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        // Generate normal click
        guard let normalBuffer = AVAudioPCMBuffer(pcmFormat: mainMixerFormat, frameCapacity: frameCount) else {
            print("Failed to create normal audio buffer")
            return
        }
        normalBuffer.frameLength = frameCount
        normalClickBuffer = normalBuffer
        
        // Generate accented click
        guard let accentedBuffer = AVAudioPCMBuffer(pcmFormat: mainMixerFormat, frameCapacity: frameCount) else {
            print("Failed to create accented audio buffer")
            return
        }
        accentedBuffer.frameLength = frameCount
        accentedClickBuffer = accentedBuffer
        
        // Generate normal click sound
        for channel in 0..<Int(channelCount) {
            guard let channelData = normalClickBuffer!.floatChannelData?[channel] else { 
                print("Failed to access normal channel \(channel)")
                continue 
            }
            
            for i in 0..<Int(frameCount) {
                let t = Double(i) / sampleRate
                let fadeIn = min(1.0, t / 0.01) // 10ms fade in
                let fadeOut = min(1.0, (duration - t) / 0.01) // 10ms fade out
                let envelope = fadeIn * fadeOut
                
                let sample = sin(2.0 * .pi * normalFrequency * t) * envelope * 0.3
                channelData[i] = Float(sample)
            }
        }
        
        // Generate accented click sound (higher pitch and slightly louder)
        for channel in 0..<Int(channelCount) {
            guard let channelData = accentedClickBuffer!.floatChannelData?[channel] else { 
                print("Failed to access accented channel \(channel)")
                continue 
            }
            
            for i in 0..<Int(frameCount) {
                let t = Double(i) / sampleRate
                let fadeIn = min(1.0, t / 0.01) // 10ms fade in
                let fadeOut = min(1.0, (duration - t) / 0.01) // 10ms fade out
                let envelope = fadeIn * fadeOut
                
                let sample = sin(2.0 * .pi * accentedFrequency * t) * envelope * 0.4
                channelData[i] = Float(sample)
            }
        }
        
        print("Click sounds generated successfully")
    }
    
    private func setupAudioSessionNotifications() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            
            guard let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
            }
            
            switch type {
            case .began:
                print("Audio session interruption began")
            case .ended:
                print("Audio session interruption ended")
                // Restart audio engine after interruption
                do {
                    try self.audioEngine.start()
                } catch {
                    print("Failed to restart audio engine after interruption: \(error)")
                }
            @unknown default:
                break
            }
        }
    }
    
    func start() {
        guard !isPlaying else { return }
        
        isPlaying = true
        let interval = 60.0 / Double(bpm)
        var beatCount = 1
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Reset beat count when we complete a measure
            if beatCount >= self.timeSignature.beats {
                beatCount = 0
            }
            
            beatCount += 1
            
            DispatchQueue.main.async {
                self.currentBeat = beatCount
            }
            self.playClick(beatIndex: beatCount - 1) // Convert to 0-based index for accent system
            
        }
        
        // Play first click immediately
        playClick(beatIndex: 0)
    }
    
    func stop() {
        isPlaying = false
        currentBeat = 0
        timer?.invalidate()
        timer = nil
    }
    
    private func playClick(beatIndex: Int) {
        let isAccented = accentedBeats.contains(beatIndex)
        let buffer = isAccented ? accentedClickBuffer : normalClickBuffer
        
        guard let buffer = buffer else {
            print("No click buffer available")
            return 
        }
        
        // Ensure audio engine is running
        if !audioEngine.isRunning {
            print("Audio engine not running, attempting to restart...")
            do {
                try audioEngine.start()
            } catch {
                print("Failed to restart audio engine: \(error)")
                return
            }
        }
        
        let clickType = isAccented ? "accented" : "normal"
        print("Playing \(clickType) click for beat \(beatIndex): format=\(buffer.format), frameLength=\(buffer.frameLength)")
        clickPlayer.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        clickPlayer.play()
    }
    
    func setBPM(_ newBPM: Int) {
        bpm = newBPM
        
        if isPlaying {
            stop()
            start()
        }
    }
    
    func setTimeSignature(_ signature: TimeSignature) {
        timeSignature = signature
        // Stop metronome when time signature changes to prevent confusion
        if isPlaying {
            stop()
        }
        // Reset accented beats to just the first beat when changing time signature
        accentedBeats = [0]
    }
    
    func toggleAccent(for beatIndex: Int) {
        if accentedBeats.contains(beatIndex) {
            accentedBeats.remove(beatIndex)
        } else {
            accentedBeats.insert(beatIndex)
        }
    }
    
    func isAccented(beatIndex: Int) -> Bool {
        return accentedBeats.contains(beatIndex)
    }
    
    deinit {
        stop()
        NotificationCenter.default.removeObserver(self)
    }
}
