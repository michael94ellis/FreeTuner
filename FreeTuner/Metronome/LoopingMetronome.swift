//
//  LoopingMetronome.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/26/25.
//

import AVFoundation
import Combine

class LoopingMetronome: ObservableObject {
    private let engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    private var buffer: AVAudioPCMBuffer?
    
    @Published var timeSignature: TimeSignature = .fourFour
    @Published var accentedBeats: Set<Int> = [0] // Beat 0 (first beat) is accented by default
    @Published var isPlaying: Bool = false
    @Published var currentBeat: Int = 0
    
    // Audio buffers for click sounds
    private var normalClickBuffer: AVAudioPCMBuffer?
    private var accentedClickBuffer: AVAudioPCMBuffer?
    
    @Published var bpm: Double
    private let sampleRate: Double = 44100
    private let clickLength: Int = 200
    
    private var beatCounter: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    init(bpm: Double = 120, timeSignature: TimeSignature = .fourFour) {
        self.bpm = bpm
        self.timeSignature = timeSignature
        setupEngine()
        generateBuffer()
        installTap()
        
        // Listen for time signature changes and regenerate buffer
        $timeSignature
            .dropFirst() // Skip the initial value
            .sink { [weak self] _ in
                self?.regenerateBuffer()
            }
            .store(in: &cancellables)
    }
    
    private func setupEngine() {
        engine.attach(player)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }
    
    private func generateBuffer() {
        let beatInterval = 60.0 / bpm
        let totalSamples = Int(sampleRate * beatInterval * Double(timeSignature.beats))
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalSamples))!
        buffer.frameLength = AVAudioFrameCount(totalSamples)
        
        for beat in 0..<timeSignature.beats {
            let sampleIndex = Int(Double(beat) * beatInterval * sampleRate)
            let isAccented = accentedBeats.contains(beat)
            insertClick(at: sampleIndex, in: buffer, isAccented: isAccented)
        }
        
        self.buffer = buffer
    }
    
    private func regenerateBuffer() {
        // Stop current playback if playing
        let wasPlaying = isPlaying
        if wasPlaying {
            player.stop()
        }
        
        // Reset beat counter
        beatCounter = 0
        currentBeat = 0
        
        // Generate new buffer with updated time signature
        generateBuffer()
        
        // Restart if it was playing
        if wasPlaying {
            start()
        }
    }
    
    private func insertClick(at sampleIndex: Int, in buffer: AVAudioPCMBuffer, isAccented: Bool = false) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let amplitude: Float = isAccented ? 0.8 : 0.5 // Louder for accented beats
        
        for i in 0..<clickLength {
            let frequency = isAccented ? 800.0 : 600.0 // Higher pitch for accented beats
            let amplitudeValue = amplitude * Float(sin(2.0 * .pi * frequency * Double(i) / sampleRate))
            let index = sampleIndex + i
            if index < Int(buffer.frameLength) {
                channelData[index] += amplitudeValue
            }
        }
    }
    
    private func installTap() {
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 512, format: format) { [weak self] buffer, _ in
            guard let self = self else { return }
            guard let channelData = buffer.floatChannelData?[0] else { return }
            
            let threshold: Float = 0.3
            for i in 0..<Int(buffer.frameLength) {
                if abs(channelData[i]) > threshold {
                    DispatchQueue.main.async {
                        self.beatCounter = (self.beatCounter + 1) % self.timeSignature.beats
                        self.currentBeat = self.beatCounter + 1 // Display 1-based beat numbers
                    }
                    break
                }
            }
        }
    }
    
    func start() {
        guard let buffer = buffer else { return }
        player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        player.play()
        isPlaying = true
    }
    
    func stop() {
        player.stop()
        isPlaying = false
        currentBeat = 0
        beatCounter = 0
    }
    
    func setBPM(_ newBPM: Double) {
        bpm = newBPM
        regenerateBuffer()
    }
    
    func setTimeSignature(_ newTimeSignature: TimeSignature) {
        timeSignature = newTimeSignature
        // Reset accented beats to just the first beat when changing time signature
        accentedBeats = [0]
    }
    
    func toggleAccent(for beatIndex: Int) {
        if accentedBeats.contains(beatIndex) {
            accentedBeats.remove(beatIndex)
        } else {
            accentedBeats.insert(beatIndex)
        }
        regenerateBuffer()
    }
    
    func isAccented(beatIndex: Int) -> Bool {
        return accentedBeats.contains(beatIndex)
    }
}
