//
//  LandscapePianoKeyboard.swift
//  MiniSynth
//
//  Created by Arya Mirsepasi on 23.05.25.
//

import SwiftUI

struct LandscapePianoKeyboard: View {
    let onNotePressed: (Float) -> Void
    let onNoteReleased: () -> Void
    
    // 8-octave piano keyboard starting from C0
    private let notes: [(String, Float, Bool)] = {
        let baseFrequencies: [(String, Float, Bool)] = [
            ("C", 16.35, false), ("C#", 17.32, true), ("D", 18.35, false),
            ("D#", 19.45, true), ("E", 20.60, false), ("F", 21.83, false),
            ("F#", 23.12, true), ("G", 24.50, false), ("G#", 25.96, true),
            ("A", 27.50, false), ("A#", 29.14, true), ("B", 30.87, false)
        ]
        
        var allNotes: [(String, Float, Bool)] = []
        
        // Generate 8 octaves (C0 to B7)
        for octave in 0...7 {
            for (note, baseFreq, isBlack) in baseFrequencies {
                let frequency = baseFreq * pow(2.0, Float(octave))
                let noteName = octave < 3 ? note : note // Keep note names simple
                allNotes.append((noteName, frequency, isBlack))
            }
        }
        
        return allNotes
    }()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                    if note.2 { // Black key
                        LandscapeBlackKey(
                            note: note.0,
                            frequency: note.1,
                            onPressed: onNotePressed,
                            onReleased: onNoteReleased
                        )
                        .zIndex(1)
                        .offset(x: -12) // Reduced offset for better connection
                    } else { // White key
                        LandscapeWhiteKey(
                            note: note.0,
                            frequency: note.1,
                            onPressed: onNotePressed,
                            onReleased: onNoteReleased
                        )
                        .zIndex(0)
                    }
                }
            }
            .padding(.horizontal, 10) // Reduced padding
        }
        .frame(height: 280) // Increased height
    }
}

struct LandscapeWhiteKey: View {
    let note: String
    let frequency: Float
    let onPressed: (Float) -> Void
    let onReleased: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Rectangle() // Changed from RoundedRectangle for better connection
            .fill(
                isPressed ?
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.6),
                        Color.white.opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ) :
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color.white // Removed transparency - solid white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 40, height: 240) // Increased height, reduced width for more keys
            .overlay(
                Rectangle()
                    .stroke(Color.black.opacity(0.3), lineWidth: 0.5) // Thinner border
            )
            .overlay(
                Text(note)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                    .offset(y: 100) // Adjusted position for larger height
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .shadow(
                color: .black.opacity(0.15),
                radius: isPressed ? 1 : 3,
                x: 0,
                y: isPressed ? 1 : 2
            )
            .animation(.easeInOut(duration: 0.08), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            playNote()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        onReleased()
                    }
            )
    }
    
    private func playNote() {
        onPressed(frequency)
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

struct LandscapeBlackKey: View {
    let note: String
    let frequency: Float
    let onPressed: (Float) -> Void
    let onReleased: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Rectangle()
            .fill(
                isPressed ?
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.9),
                        Color.black.opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ) :
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.2),
                        Color.black
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 24, height: 160) 
            .overlay(
                Text(note)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .offset(y: 60)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: .black.opacity(0.5),
                radius: isPressed ? 1 : 3,
                x: 0,
                y: isPressed ? 1 : 3
            )
            .animation(.easeInOut(duration: 0.08), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            playNote()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        onReleased()
                    }
            )
    }
    
    private func playNote() {
        onPressed(frequency)
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}
