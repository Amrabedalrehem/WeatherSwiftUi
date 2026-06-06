//
//  ManageCitiesBackground.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 06/06/2026.
//


import SwiftUI

struct ManageCitiesBackground: View {
    let weatherResponse: WeatherResponse?
    let currentCondition: String
    let isDay: Bool

    var body: some View {
        ZStack {
            if weatherResponse != nil {
                VideoBackgroundView(condition: currentCondition, isDay: isDay)
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.12, blue: 0.28),
                        Color(red: 0.10, green: 0.22, blue: 0.42)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }

            Color.black.opacity(isDay ? 0.15 : 0.35)
                .ignoresSafeArea()
        }
    }
}


struct ManageCitiesHeader: View {
    let fontColor: Color
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Home")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(fontColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
            }

            Spacer()

            Text("Manage Cities")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(fontColor)

            Spacer()

            Color.clear.frame(width: 80, height: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 12)
    }
}


struct SectionLabel: View {
    let icon: String
    let title: String
    let fontColor: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(icon == "star.fill" ? .yellow : fontColor.opacity(0.75))
                .font(.system(size: 11))
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(fontColor.opacity(0.75))
        }
    }
}
