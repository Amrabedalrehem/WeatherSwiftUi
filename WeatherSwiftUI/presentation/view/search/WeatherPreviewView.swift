//
//  WeatherPreviewView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 02/06/2026.
//

import SwiftUI

struct WeatherPreviewView: View {
    let weather: WeatherResponse
    @Environment(\.dismiss) var dismiss
    @State private var selectedDay: ForecastDay?

    var body: some View {
        ZStack(alignment: .topLeading) {
              WeatherPageView(
                weather: weather,
                isCurrentLocation: false,
                selectedDay: $selectedDay
            )

              Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Search")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(.top, 60)
            .padding(.leading, 20)
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
            .navigationDestination(item: $selectedDay) { day in
            HourlyView(forecastDay: day, fontColor: .white)
        }
    }
}
