//
//  SplashScreenView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 03/06/2026.
//

import SwiftUI

struct SplashScreenView: View {

    @State private var iconScale:      CGFloat = 0.4
    @State private var iconOpacity:    Double  = 0.0
    @State private var titleOpacity:   Double  = 0.0
    @State private var titleOffset:    CGFloat = 30
    @State private var subtitleOpacity:Double  = 0.0
    @State private var subtitleOffset: CGFloat = 20
    @State private var glowOpacity:    Double  = 0.0
    @State private var glowScale:      CGFloat = 0.6
    @State private var ringScale:      CGFloat = 0.5
    @State private var ringOpacity:    Double  = 0.0
    @State private var particleVisible: Bool   = false
    @State private var shimmer:        CGFloat = -200

    let onFinished: () -> Void

    var body: some View {
        ZStack {
              LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.06, blue: 0.18),
                    Color(red: 0.06, green: 0.14, blue: 0.32),
                    Color(red: 0.10, green: 0.22, blue: 0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
     if particleVisible {
                ForEach(0..<60, id: \.self) { i in
                    StarParticle(index: i)
                }
            }
      Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.cyan.opacity(0.5),
                            Color.blue.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 220, height: 220)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)
                .blur(radius: 1)

                      Circle()
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
                .frame(width: 170, height: 170)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)
         Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.cyan.opacity(0.35),
                            Color.blue.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 90
                    )
                )
                .frame(width: 180, height: 180)
                .scaleEffect(glowScale)
                .opacity(glowOpacity)
                .blur(radius: 20)

            VStack(spacing: 28) {
                   ZStack {
                        Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)

                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 120, height: 120)
     Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.25),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .mask(
                            Rectangle()
                                .frame(width: 60, height: 120)
                                .offset(x: shimmer)
                        )

                          Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 54, weight: .medium))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            Color.yellow,
                            Color.white.opacity(0.9)
                        )
                        .shadow(color: .yellow.opacity(0.5), radius: 10, x: 0, y: 0)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
     VStack(spacing: 8) {
                    Text("WeatherCast")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.cyan.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .opacity(titleOpacity)
                        .offset(y: titleOffset)
                        .shadow(color: .cyan.opacity(0.4), radius: 12, x: 0, y: 4)

                    Text("Your Personal Weather Companion")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))
                        .opacity(subtitleOpacity)
                        .offset(y: subtitleOffset)
                }
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
 private struct StarParticle: View {
    let index: Int
    @State private var opacity: Double = 0

    private let x: CGFloat
    private let y: CGFloat
    private let size: CGFloat
    private let delay: Double

    init(index: Int) {
        self.index = index
        var rng = SystemRandomNumberGenerator()
        x     = CGFloat.random(in: -180...180, using: &rng)
        y     = CGFloat.random(in: -380...380, using: &rng)
        size  = CGFloat.random(in: 1...3,      using: &rng)
        delay = Double.random(in: 0...0.8,     using: &rng)
    }

    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: size, height: size)
            .offset(x: x, y: y)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5).delay(delay)) {
                    opacity = Double.random(in: 0.3...0.9)
                }
            }
    }
}

