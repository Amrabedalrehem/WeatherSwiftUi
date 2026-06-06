//
//  SearchBackground.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 06/06/2026.
//


import SwiftUI

 
struct SearchBackground: View {
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

 struct SearchHeader: View {
    let fontColor: Color
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(fontColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
            }
            Spacer()
            Text("Search")
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
 struct SearchBar: View {
    @Binding var searchText: String
    let onClear: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.7))
                .font(.system(size: 16, weight: .semibold))

            TextField("", text: $searchText, prompt:
                Text("Search city...").foregroundColor(.white.opacity(0.5))
            )
            .foregroundColor(.white)
            .font(.system(size: 16))
            .autocorrectionDisabled()
            .onSubmit { onSubmit() }

            if !searchText.isEmpty {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 18))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.3), lineWidth: 1))
    }
}
