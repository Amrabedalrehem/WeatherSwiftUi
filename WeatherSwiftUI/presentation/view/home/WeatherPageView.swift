//
//  WeatherPageView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 02/06/2026.
//

import SwiftUI

struct WeatherPageView: View {

    let weather: WeatherResponse
    let isCurrentLocation: Bool
    @Binding var selectedDay: ForecastDay?
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var showRemoveAlert: Bool = false

    private func checkIfIsDay() -> Bool {
        return weather.current.is_day == 1   
    }

    private var fontColor: Color { .white }

    var body: some View {
        ZStack {
             VideoBackgroundView(
                condition: weather.current.condition.text,
                isDay: checkIfIsDay()
            )
            .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {

                     VStack(spacing: 8) {
                        HStack(spacing: 10) {
                            Spacer()

                            if isCurrentLocation {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(fontColor.opacity(0.7))
                            }

                            Text(weather.location.name)
                                .font(.system(size: 34, weight: .medium))
                                .foregroundColor(fontColor)

                            if !isCurrentLocation {
                                Button(action: {
                                    if viewModel.isLocationSaved(name: weather.location.name) {
                                          showRemoveAlert = true
                                    } else {
                                          let location = SavedLocation(
                                            name: weather.location.name,
                                            lat: weather.location.lat,
                                            lon: weather.location.lon,
                                            country: weather.location.country
                                        )
                                        viewModel.toggleLocationFromSearch(location: location)
                                    }
                                }) {
                                    Image(systemName: viewModel.isLocationSaved(name: weather.location.name) ? "star.fill" : "star")
                                        .foregroundColor(viewModel.isLocationSaved(name: weather.location.name) ? .yellow : fontColor)
                                        .font(.system(size: 22))
                                }
                                .alert("Remove Favorite?", isPresented: $showRemoveAlert) {
                                    Button("Remove", role: .destructive) {
                                        let location = SavedLocation(
                                            name: weather.location.name,
                                            lat: weather.location.lat,
                                            lon: weather.location.lon,
                                            country: weather.location.country
                                        )
                                        viewModel.toggleLocationFromSearch(location: location)
                                    }
                                    Button("Cancel", role: .cancel) { }
                                } message: {
                                    Text("Are you sure you want to remove \(weather.location.name) from your favorites?")
                                }
                            }

                            Spacer()
                        }
                        .padding(.top, 50)

                        Text("\(Int(weather.current.temp_c))°")
                            .font(.system(size: 80, weight: .thin))
                            .foregroundColor(fontColor)

                        Text(weather.current.condition.text)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(fontColor.opacity(0.8))

                        Text("H:\(Int(weather.forecast.forecastday.first?.day.maxtemp_c ?? 0))°  L:\(Int(weather.forecast.forecastday.first?.day.mintemp_c ?? 0))°")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(fontColor.opacity(0.8))
                    }
                        if let firstDay = weather.forecast.forecastday.first {
                        GlassCardView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("HOURLY FORECAST")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(fontColor.opacity(0.6))

                                Divider().background(fontColor.opacity(0.3))

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20) {
                                        ForEach(firstDay.hour.prefix(6), id: \.time) { hour in
                                            VStack(spacing: 8) {
                                                Text(formatToHour(hour.time))
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(fontColor)

                                                AsyncImage(url: URL(string: "https:\(hour.condition.icon)")) { image in
                                                    image.resizable().scaledToFit()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(width: 30, height: 30)

                                                Text("\(Int(hour.temp_c))°")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(fontColor)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                        GlassCardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("3-DAY FORECAST", systemImage: "calendar")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(fontColor.opacity(0.6))

                            Divider().background(fontColor.opacity(0.3))

                            ForEach(weather.forecast.forecastday, id: \.date) { day in
                                Button {
                                    selectedDay = day
                                } label: {
                                    ForecastRowView(forecastDay: day, fontColor: fontColor)
                                }
                                .buttonStyle(.plain)

                                if day.date != weather.forecast.forecastday.last?.date {
                                    Divider().background(fontColor.opacity(0.2))
                                }
                            }
                        }
                    }

                    WeatherDetailGridView(current: weather.current, fontColor: fontColor)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
        }
    }

    private func formatToHour(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let date = formatter.date(from: timeString) else { return timeString }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h a"
        return outputFormatter.string(from: date)
    }
}
