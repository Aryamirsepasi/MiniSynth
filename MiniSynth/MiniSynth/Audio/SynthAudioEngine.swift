//
//  SynthAudioEngine.swift
//  MiniSynth
//
//  Created by Arya Mirsepasi on 23.05.25.
//

import AVFoundation
import Observation

@Observable
class SynthAudioEngine {
    private let audioEngine = AVAudioEngine()
    private var synthNode: AVAudioSourceNode!
    private let filterNode = AVAudioUnitEQ(numberOfBands: 1)
    private let reverbNode = AVAudioUnitReverb()
    private let mixer = AVAudioMixerNode()
    
    // Synthesis parameters
    var oscillatorType: OscillatorType = .sine
    var filterFrequency: Float = 1000.0
    var filterResonance: Float = 0.5
    var reverbWetness: Float = 0.2
    var masterVolume: Float = 0.7
    
    // ADSR envelope parameters
    var attack: Float = 0.1
    var decay: Float = 0.3
    var sustain: Float = 0.6
    var release: Float = 0.8
    
    private var currentPhase: Float = 0
    private var isPlaying = false
    private var currentFrequency: Float = 440.0
    private var sampleRate: Float = 44100.0
    private var envelopeLevel: Float = 0.0
    private var noteOnTime: Float = 0.0
    private var noteOffTime: Float = 0.0
    private var currentTime: Float = 0.0
    private var hasPlayedOnce = false

    
    enum OscillatorType {
        case sine, square, sawtooth
    }
    
    init() {
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        let outputFormat = audioEngine.outputNode.outputFormat(forBus: 0)
        sampleRate = Float(outputFormat.sampleRate)
        
        // Configure synthesis node with proper initializer
        synthNode = AVAudioSourceNode { [weak self] _, timeStamp, frameCount, audioBufferList in
            guard let self = self else { return noErr }
            return self.renderAudio(
                timeStamp: timeStamp,
                frameCount: frameCount,
                audioBufferList: audioBufferList
            )
        }
        
        // Configure filter
        let filterBand = filterNode.bands[0]
        filterBand.filterType = .lowPass
        filterBand.frequency = filterFrequency
        filterBand.bandwidth = filterResonance
        filterBand.gain = 0
        filterBand.bypass = false
        
        // Configure reverb
        reverbNode.wetDryMix = reverbWetness * 100
        reverbNode.loadFactoryPreset(.smallRoom)
        
        // Audio graph: synth -> filter -> reverb -> mixer -> output
        audioEngine.attach(synthNode)
        audioEngine.attach(filterNode)
        audioEngine.attach(reverbNode)
        audioEngine.attach(mixer)
        
        audioEngine.connect(synthNode, to: filterNode, format: outputFormat)
        audioEngine.connect(filterNode, to: reverbNode, format: outputFormat)
        audioEngine.connect(reverbNode, to: mixer, format: outputFormat)
        audioEngine.connect(mixer, to: audioEngine.outputNode, format: outputFormat)
        
        mixer.outputVolume = masterVolume
        
        startEngine()
    }
    
    private func startEngine() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
        } catch {
            print("Audio engine start error: \(error)")
        }
    }
    
    private func renderAudio(
        timeStamp: UnsafePointer<AudioTimeStamp>,
        frameCount: AVAudioFrameCount,
        audioBufferList: UnsafeMutablePointer<AudioBufferList>
    ) -> OSStatus {
        let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
        let buffers: [UnsafeMutableBufferPointer<Float>] = abl.map {
          UnsafeMutableBufferPointer<Float>($0)
        }
        
        for frame in 0..<Int(frameCount) {
            currentTime += 1.0 / sampleRate
            
            // Calculate envelope
            updateEnvelope()
            
            // Generate oscillator sample
            let sample = generateOscillator() * envelopeLevel * 0.3 // Reduce volume
            
            // Write to both channels
            for buffer in buffers {
                buffer[frame] = sample
            }
            
            // Update phase
            currentPhase += (currentFrequency * 2.0 * .pi) / sampleRate
            if currentPhase > 2.0 * .pi {
                currentPhase -= 2.0 * .pi
            }
        }
        
        return noErr
    }
    
    private func generateOscillator() -> Float {
        switch oscillatorType {
        case .sine:
            return sin(currentPhase)
        case .square:
            return currentPhase < .pi ? 1.0 : -1.0
        case .sawtooth:
            return (currentPhase / .pi) - 1.0
        }
    }
    
    private func updateEnvelope() {
        if isPlaying {
            let timeSinceNoteOn = currentTime - noteOnTime
            
            if timeSinceNoteOn < attack {
                // Attack phase
                envelopeLevel = timeSinceNoteOn / attack
            } else if timeSinceNoteOn < attack + decay {
                // Decay phase
                let decayProgress = (timeSinceNoteOn - attack) / decay
                envelopeLevel = 1.0 - (decayProgress * (1.0 - sustain))
            } else {
                // Sustain phase
                envelopeLevel = sustain
            }
        } else if hasPlayedOnce {
            // Release phase
            let timeSinceNoteOff = currentTime - noteOffTime
            if timeSinceNoteOff < release {
                let releaseProgress = timeSinceNoteOff / release
                envelopeLevel = sustain * (1.0 - releaseProgress)
            }
        } else {
                envelopeLevel = 0.0
            }
        
        envelopeLevel = max(0.0, min(1.0, envelopeLevel))
    }
    
    func playNote(frequency: Float) {
        hasPlayedOnce = true
        currentFrequency = frequency
        noteOnTime = currentTime
        isPlaying = true
    }
    
    func stopNote() {
        noteOffTime = currentTime
        isPlaying = false
    }
    
    func updateParameters() {
        // Update filter parameters
        let filterBand = filterNode.bands[0]
        filterBand.frequency = filterFrequency
        filterBand.bandwidth = filterResonance
        
        // Update reverb
        reverbNode.wetDryMix = reverbWetness * 100
        
        // Update volume
        mixer.outputVolume = masterVolume
    }
}
