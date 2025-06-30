//
//  BraunSegmentedPicker.swift
//  MiniSynth
//
//  Created by Arya Mirsepasi on 23.05.25.
//

import SwiftUI

struct BraunSegmentedPicker<T: Hashable>: View {
    @Binding var selection: T
    let options: [(T, String)]
    
    @Namespace private var selectionAnimation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                let isSelected = selection == option.0
                let isFirst = index == 0
                let isLast = index == options.count - 1
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = option.0
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                }) {
                    Text(option.1)
                        .font(.system(size: 10, weight: .medium, design: .default))
                        .foregroundColor(
                            isSelected ?
                            Color.white :
                            Color(red: 0.4, green: 0.4, blue: 0.4)
                        )
                        .tracking(1.2)
                        .frame(height: 32)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                if isSelected {
                                    RoundedRectangle(
                                        cornerRadius: 6,
                                        style: .continuous
                                    )
                                    .fill(Color(red: 1.0, green: 0.42, blue: 0.21)) // Braun orange
                                    .matchedGeometryEffect(
                                        id: "selection",
                                        in: selectionAnimation
                                    )
                                    .shadow(
                                        color: Color(red: 1.0, green: 0.42, blue: 0.21).opacity(0.3),
                                        radius: 3,
                                        x: 0,
                                        y: 2
                                    )
                                }
                            }
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 6,
                                style: .continuous
                            )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 2,
                    x: 0,
                    y: 1
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                )
        )
        .frame(width: 200)
    }
}

extension BraunSegmentedPicker {
    init(selection: Binding<T>, options: [T]) where T: CaseIterable & RawRepresentable, T.RawValue == String {
        self._selection = selection
        self.options = options.map { ($0, $0.rawValue) }
    }
}
