//
//  ContentView.swift
//  MiniSynth
//
//  Created by Arya Mirsepasi on 23.05.25.
//

import SwiftUI

struct ContentView: View {
    @State private var synthEngine = SynthAudioEngine()
    @State private var showingSettings = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Braun-style light background
                Color(red: 0.96, green: 0.96, blue: 0.96).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top bar with title and settings
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("MINISYNTH")
                                .font(.system(size: 18, weight: .medium, design: .default))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                .tracking(2)
                            
                            Text("8-Octave Real-time Synthesis by Arya Mirsepasi")
                                .font(.system(size: 9, weight: .regular, design: .default))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                .tracking(0.8)
                        }
                        
                        Spacer()
                        
                        // Custom Braun-style oscillator selector
                        BraunSegmentedPicker(
                            selection: $synthEngine.oscillatorType,
                            options: [
                                (SynthAudioEngine.OscillatorType.sine, "SINE"),
                                (SynthAudioEngine.OscillatorType.square, "SQUARE"),
                                (SynthAudioEngine.OscillatorType.sawtooth, "SAW")
                            ]
                        )
                        
                        Spacer()
                        
                        // Settings button
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white)
                                        .shadow(
                                            color: Color.black.opacity(0.1),
                                            radius: 2,
                                            x: 0,
                                            y: 1
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Main piano keyboard
                    LandscapePianoKeyboard(
                        onNotePressed: { frequency in
                            synthEngine.playNote(frequency: frequency)
                        },
                        onNoteReleased: {
                            synthEngine.stopNote()
                        }
                    )
                    .padding(.bottom, 20)
                }
            }
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingSettings) {
            SettingsSheet(synthEngine: $synthEngine)
        }
        .onChange(of: synthEngine.oscillatorType) {
            synthEngine.updateParameters()
        }
    }
}

// Settings Sheet
struct SettingsSheet: View {
    @Binding var synthEngine: SynthAudioEngine
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 50) {
                        // Oscillator Type Section
                        SynthSection(title: "Oscillator") {
                            HStack {
                                BraunSegmentedPicker(
                                    selection: $synthEngine.oscillatorType,
                                    options: [
                                        (SynthAudioEngine.OscillatorType.sine, "SINE"),
                                        (SynthAudioEngine.OscillatorType.square, "SQUARE"),
                                        (SynthAudioEngine.OscillatorType.sawtooth, "SAW")
                                    ]
                                )
                                Spacer()
                            }
                        }
                        
                        // Volume Control
                        SynthSection(title: "Master") {
                            HStack {
                                Spacer()
                                LargeBraunKnob(
                                    value: $synthEngine.masterVolume,
                                    range: 0...1,
                                    label: "Volume"
                                )
                                Spacer()
                            }
                        }
                        
                        // Filter & Effects Section
                        SynthSection(title: "Filter & Effects") {
                            HStack(spacing: 60) {
                                LargeBraunKnob(
                                    value: $synthEngine.filterFrequency,
                                    range: 100...5000,
                                    label: "Filter Freq"
                                )
                                
                                LargeBraunKnob(
                                    value: $synthEngine.filterResonance,
                                    range: 0.1...2.0,
                                    label: "Resonance"
                                )
                                
                                LargeBraunKnob(
                                    value: $synthEngine.reverbWetness,
                                    range: 0...1,
                                    label: "Reverb"
                                )
                            }
                        }
                        
                        // ADSR Envelope Section
                        SynthSection(title: "ADSR Envelope") {
                            VStack(spacing: 30) {
                                HStack(spacing: 30) {
                                    BraunSlider(
                                        value: $synthEngine.attack,
                                        range: 0.01...2.0,
                                        label: "Attack"
                                    )
                                    
                                    BraunSlider(
                                        value: $synthEngine.decay,
                                        range: 0.01...2.0,
                                        label: "Decay"
                                    )
                                }
                                
                                HStack(spacing: 30) {
                                    BraunSlider(
                                        value: $synthEngine.sustain,
                                        range: 0...1,
                                        label: "Sustain"
                                    )
                                    
                                    BraunSlider(
                                        value: $synthEngine.release,
                                        range: 0.01...3.0,
                                        label: "Release"
                                    )
                                }
                            }
                        }
                        
                        
                        HStack {
                            Spacer()
                            Label {
                                Text("Arya Mirsepasi 2025")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            } icon: {
                                Image(systemName: "c.circle")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            }
                            Spacer()
                        }
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 30)
                }
            }
            .background(Color(red: 0.96, green: 0.96, blue: 0.96))
            .navigationTitle("SYNTHESIS SETTINGS")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                                    Button("DONE") {
                dismiss()
            }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                .tracking(1)
            )
            .onChange(of: synthEngine.filterFrequency) {
                synthEngine.updateParameters()
            }
            .onChange(of: synthEngine.filterResonance) {
                synthEngine.updateParameters()
            }
            .onChange(of: synthEngine.reverbWetness) {
                synthEngine.updateParameters()
            }
            .onChange(of: synthEngine.masterVolume) {
                synthEngine.updateParameters()
            }
        }
        .preferredColorScheme(.light)
    }
}

// Section Container
struct SynthSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .medium, design: .default))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                    .tracking(2)
                
                Spacer()
            }
            
            content
        }
        .padding(.vertical, 10)
    }
}
