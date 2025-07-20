//
//  BraunSlider.swift
//  MiniSynth
//
//  Created by Arya Mirsepasi on 23.05.25.
//

import SwiftUI

struct BSlider: View {
    @Binding var value: Float
    let range: ClosedRange<Float>
    let label: String
    
    @State private var isDragging = false
    private let thumbSize: CGFloat = 20
    private let trackHeight: CGFloat = 6
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .medium, design: .default))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                    .tracking(1.5)
                Spacer()
                Text(formattedValue)
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            }
            
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let thumbRadius = thumbSize / 2
                let trackWidth = totalWidth - thumbSize
                let thumbOffset = CGFloat(normalizedValue) * trackWidth + thumbRadius
                
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(Color(red: 0.92, green: 0.92, blue: 0.92))
                        .frame(width: totalWidth, height: trackHeight)
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 1,
                            x: 0,
                            y: 1
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: trackHeight / 2)
                                .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
                        )
                        .position(x: totalWidth / 2, y: 20)
                    
                    // Active track
                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(Color(red: 1.0, green: 0.42, blue: 0.21)) // Braun orange
                        .frame(
                            width: max(trackHeight, thumbOffset - thumbRadius + trackHeight),
                            height: trackHeight
                        )
                        .position(x: (thumbOffset - thumbRadius + trackHeight) / 2, y: 20)
                    
                    // Thumb
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white,
                                    Color(red: 0.95, green: 0.95, blue: 0.95)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: isDragging ? 4 : 2,
                            x: 0,
                            y: isDragging ? 2 : 1
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                        )
                        .position(x: thumbOffset, y: 20)
                        .scaleEffect(isDragging ? 1.05 : 1.0)
                        .animation(.easeOut(duration: 0.15), value: isDragging)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            isDragging = true
                            
                            let clampedX = max(thumbRadius, min(totalWidth - thumbRadius, gesture.location.x))
                            let normalizedPosition = (clampedX - thumbRadius) / trackWidth
                            let newValue = Float(normalizedPosition) * (range.upperBound - range.lowerBound) + range.lowerBound
                            
                            value = max(range.lowerBound, min(range.upperBound, newValue))
                            
                            if Int(value * 50) % 5 == 0 {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
            }
            .frame(height: 40)
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
