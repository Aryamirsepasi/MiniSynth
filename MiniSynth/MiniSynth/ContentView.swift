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
            SettingsView(synthEngine: $synthEngine)
        }
        .onChange(of: synthEngine.oscillatorType) {
            synthEngine.updateParameters()
        }
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
