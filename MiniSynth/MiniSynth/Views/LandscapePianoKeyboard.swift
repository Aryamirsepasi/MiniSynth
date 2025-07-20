//
//  LandscapePianoKeyboard.swift
//  MiniSynth
//
//  Updated 20 Jul 2025
//

import SwiftUI

struct LandscapePianoKeyboard: View {

    let onNotePressed: (Float) -> Void
    let onNoteReleased: () -> Void

    // Constants
    private let whiteKeyWidth:  CGFloat = 40
    private let whiteKeyHeight: CGFloat = 240
    private let blackKeyWidth:  CGFloat = 24
    private let blackKeyHeight: CGFloat = 160

    // Note table (8 octaves : C0 – B7)
    private let notes: [(name: String, freq: Float, isBlack: Bool)] = {
        let base: [(String, Float, Bool)] = [
            ("C",  16.35, false), ("C#", 17.32, true),  ("D",  18.35, false),
            ("D#", 19.45, true),  ("E",  20.60, false), ("F",  21.83, false),
            ("F#", 23.12, true),  ("G",  24.50, false), ("G#", 25.96, true),
            ("A",  27.50, false), ("A#", 29.14, true),  ("B",  30.87, false)
        ]

        var all: [(String, Float, Bool)] = []
        for octave in 0..<8 {
            for (note, baseFreq, black) in base {
                let f = baseFreq * pow(2.0, Float(octave))
                all.append((note, f, black))
            }
        }
        return all
    }()

    // Derived arrays
    private var whiteNotes: [(String, Float)] {
        notes.filter { !$0.isBlack }.map { ($0.name, $0.freq) }
    }

    private var blackNotesWithOffset: [(String, Float, CGFloat)] {
        var whitesBefore = 0
        var result: [(String, Float, CGFloat)] = []

        for note in notes {
            if note.isBlack {
                let x = CGFloat(whitesBefore) * whiteKeyWidth - blackKeyWidth / 2
                result.append((note.name, note.freq, x))
            } else {
                whitesBefore += 1
            }
        }
        return result
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack(alignment: .topLeading) {

                // Layer 0 – white keys
                HStack(spacing: 0) {
                    ForEach(0..<whiteNotes.count, id: \.self) { i in
                        let note = whiteNotes[i]
                        LandscapeWhiteKey(
                            note: note.0,
                            frequency: note.1,
                            onPressed: onNotePressed,
                            onReleased: onNoteReleased
                        )
                    }
                }

                // Layer 1 – black keys (absolutely positioned)
                ForEach(0..<blackNotesWithOffset.count, id: \.self) { i in
                    let note = blackNotesWithOffset[i]
                    LandscapeBlackKey(
                        note: note.0,
                        frequency: note.1,
                        onPressed: onNotePressed,
                        onReleased: onNoteReleased
                    )
                    .offset(x: note.2)
                    .zIndex(1)
                }
            }
            .padding(.horizontal, 10)
            .frame(height: whiteKeyHeight)
        }
        .frame(height: whiteKeyHeight + 40)
    }
}

// Key views
// White key
private struct LandscapeWhiteKey: View {
    let note: String
    let frequency: Float
    let onPressed: (Float) -> Void
    let onReleased: () -> Void

    @State private var isPressed = false

    private var fillStyle: AnyShapeStyle {
        if isPressed {
            return AnyShapeStyle(
                LinearGradient(
                    gradient: .init(colors: [.gray.opacity(0.6),
                                             .white.opacity(0.9)]),
                    startPoint: .top, endPoint: .bottom
                )
            )
        } else {
            return AnyShapeStyle(Color.white)
        }
    }

    var body: some View {
        Rectangle()
            .fill(fillStyle)
            .frame(width: 40, height: 240)
            .overlay(Rectangle().stroke(Color.black.opacity(0.3), lineWidth: 0.5))
            .overlay(
                Text(note)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                    .offset(y: 100)
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .shadow(color: .black.opacity(0.15),
                    radius: isPressed ? 1 : 3,
                    x: 0, y: isPressed ? 1 : 2)
            .animation(.easeInOut(duration: 0.08), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in pressIfNeeded() }
                    .onEnded   { _ in release() }
            )
    }

    private func pressIfNeeded() {
        guard !isPressed else { return }
        isPressed = true
        onPressed(frequency)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func release() {
        isPressed = false
        onReleased()
    }
}

// Black key
private struct LandscapeBlackKey: View {
    let note: String
    let frequency: Float
    let onPressed: (Float) -> Void
    let onReleased: () -> Void

    @State private var isPressed = false

    var body: some View {
        Rectangle()
            .fill(isPressed
                  ? LinearGradient(
                        gradient: .init(colors: [.gray.opacity(0.9),
                                                 .black.opacity(0.8)]),
                        startPoint: .top, endPoint: .bottom)
                  : LinearGradient(
                        gradient: .init(colors: [.gray.opacity(0.2), .black]),
                        startPoint: .top, endPoint: .bottom))
            .frame(width: 24, height: 160)
            .overlay(
                Text(note)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .offset(y: 60)
            )
            .scaleEffect(isPressed ? 0.95 : 1)
            .shadow(color: .black.opacity(0.5),
                    radius: isPressed ? 1 : 3,
                    x: 0, y: isPressed ? 1 : 3)
            .animation(.easeInOut(duration: 0.08), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in pressIfNeeded() }
                    .onEnded   { _ in release() }
            )
    }

    private func pressIfNeeded() {
        guard !isPressed else { return }
        isPressed = true
        onPressed(frequency)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func release() {
        isPressed = false
        onReleased()
    }
}
