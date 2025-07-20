//
//  LargeBraunKnob.swift
//  MiniSynth
//
//  Created by Arya Mirsepasi on 23.05.25.
//

import SwiftUI

struct LargeKnob: View {
    @Binding var value: Float
    let range: ClosedRange<Float>
    let label: String
    
    @State private var isDragging = false
    @State private var lastDragLocation: CGPoint = .zero
    
    private let knobSize: CGFloat = 80
    private let indicatorSize: CGFloat = 6
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Main knob body
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color(red: 0.92, green: 0.92, blue: 0.92)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: knobSize, height: knobSize)
                    .shadow(
                        color: Color.black.opacity(0.15),
                        radius: isDragging ? 8 : 4,
                        x: 0,
                        y: isDragging ? 4 : 2
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                
                // Progress arc
                Circle()
                    .trim(from: 0, to: CGFloat(normalizedValue))
                    .stroke(
                        Color(red: 1.0, green: 0.42, blue: 0.21), // Braun orange
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: knobSize + 8, height: knobSize + 8)
                    .rotationEffect(.degrees(-90))
                
                // Position indicator dot
                Circle()
                    .fill(Color(red: 1.0, green: 0.42, blue: 0.21)) // Braun orange
                    .frame(width: indicatorSize, height: indicatorSize)
                    .offset(y: -(knobSize / 2 - 12))
                    .rotationEffect(.degrees(Double(normalizedValue * 360 - 90)))
                
                // Center dot (subtle)
                Circle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 3, height: 3)
            }
            .scaleEffect(isDragging ? 1.02 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isDragging)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            lastDragLocation = gesture.location
                            
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                        
                        let delta = gesture.location.y - lastDragLocation.y
                        let sensitivity: Float = 0.004
                        let newValue = value - Float(delta) * sensitivity *
                                     (range.upperBound - range.lowerBound)
                        
                        value = max(range.lowerBound, min(range.upperBound, newValue))
                        lastDragLocation = gesture.location
                        
                        if Int(value * 100) % 10 == 0 {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            
            VStack(spacing: 6) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .medium, design: .default))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                    .tracking(1.5)
                
                Text(formattedValue)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            }
        }
    }
    
    private var normalizedValue: Float {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
    
    private var formattedValue: String {
        if range.upperBound > 100 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
}
