//
//  AnimatedStarButton.swift
//  WeatherSwiftUI
//

import SwiftUI

struct AnimatedStarButton: View {
    let isSaved: Bool
    let fontColor: Color
    let size: CGFloat
    let action: () -> Void

    @State private var animatePulse = false
    @State private var animateRotation = false

    var body: some View {
        Button(action: {
            let wasSaved = isSaved
            
            action()
            
              if !wasSaved {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                    animatePulse = true
                    animateRotation = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                        animatePulse = false
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    animateRotation = false
                }
            }
        }) {
            Image(systemName: isSaved ? "star.fill" : "star")
                .foregroundColor(isSaved ? .yellow : fontColor)
                .font(.system(size: size))
                  .scaleEffect(animatePulse ? 1.6 : 1.0)
                 .rotationEffect(Angle(degrees: animateRotation ? 360 : 0))
                  .shadow(color: isSaved ? .yellow.opacity(0.6) : .clear, radius: isSaved ? 6 : 0)
        }
        .buttonStyle(.plain)
    }
}
