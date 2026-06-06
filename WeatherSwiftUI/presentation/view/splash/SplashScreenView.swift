//
//  SplashScreenView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 03/06/2026.
//
 
import SwiftUI

struct SplashScreenView: View {

    @State private var iconScale:       CGFloat = 0.4
    @State private var iconOpacity:     Double  = 0.0
    @State private var titleOpacity:    Double  = 0.0
    @State private var titleOffset:     CGFloat = 30
    @State private var subtitleOpacity: Double  = 0.0
    @State private var subtitleOffset:  CGFloat = 20
    @State private var glowOpacity:     Double  = 0.0
    @State private var glowScale:       CGFloat = 0.6
    @State private var ringScale:       CGFloat = 0.5
    @State private var ringOpacity:     Double  = 0.0
    @State private var particleVisible: Bool    = false
    @State private var shimmer:         CGFloat = -200

    let onFinished: () -> Void

    var body: some View {
        ZStack {
            SplashBackground()

            if particleVisible {
                ForEach(0..<60, id: \.self) { i in
                    StarParticle(index: i)
                }
            }

            SplashRings(ringScale: ringScale, ringOpacity: ringOpacity)

            SplashGlow(glowScale: glowScale, glowOpacity: glowOpacity)

            VStack(spacing: 28) {
                SplashIcon(
                    iconScale: iconScale,
                    iconOpacity: iconOpacity,
                    shimmer: shimmer
                )

                SplashText(
                    titleOpacity: titleOpacity,
                    titleOffset: titleOffset,
                    subtitleOpacity: subtitleOpacity,
                    subtitleOffset: subtitleOffset
                )
            }
        }
        .onAppear { startAnimations() }
    }

      private func startAnimations() {
        withAnimation(.easeIn(duration: 0.6).delay(0.1)) {
            particleVisible = true
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.2)) {
            ringScale   = 1.0
            ringOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
            glowOpacity = 1.0
            glowScale   = 1.0
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.55).delay(0.35)) {
            iconScale   = 1.0
            iconOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 0.7).delay(0.8)) {
            shimmer = 200
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.7)) {
            titleOpacity = 1.0
            titleOffset  = 0
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.9)) {
            subtitleOpacity = 1.0
            subtitleOffset  = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            withAnimation(.easeInOut(duration: 0.5)) {
                onFinished()
            }
        }
    }
}
