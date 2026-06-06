//
//  SplashBackground.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 06/06/2026.
//

 
 

import SwiftUI


struct SplashBackground: View {
    var body: some View {
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
    }
}

struct SplashRings: View {
    let ringScale: CGFloat
    let ringOpacity: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.5), Color.blue.opacity(0.2), Color.clear],
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
        }
    }
}


struct SplashGlow: View {
    let glowScale: CGFloat
    let glowOpacity: Double

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color.cyan.opacity(0.35), Color.blue.opacity(0.15), Color.clear],
                    center: .center,
                    startRadius: 20,
                    endRadius: 90
                )
            )
            .frame(width: 180, height: 180)
            .scaleEffect(glowScale)
            .opacity(glowOpacity)
            .blur(radius: 20)
    }
}


struct SplashIcon: View {
    let iconScale: CGFloat
    let iconOpacity: Double
    let shimmer: CGFloat

    var body: some View {
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
                        colors: [.clear, .white.opacity(0.25), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 120, height: 120)
                .mask(Rectangle().frame(width: 60, height: 120).offset(x: shimmer))

            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 54, weight: .medium))
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.yellow, Color.white.opacity(0.9))
                .shadow(color: .yellow.opacity(0.5), radius: 10, x: 0, y: 0)
        }
        .scaleEffect(iconScale)
        .opacity(iconOpacity)
    }
}


struct SplashText: View {
    let titleOpacity: Double
    let titleOffset: CGFloat
    let subtitleOpacity: Double
    let subtitleOffset: CGFloat

    var body: some View {
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


struct StarParticle: View {
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
