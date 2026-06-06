//
//  SavedCitiesSection.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 06/06/2026.
//


import SwiftUI

struct SavedCitiesSection: View {
    let savedLocations: [SavedLocation]
    let savedWeatherResponses: [WeatherResponse]
    let fontColor: Color
    let onRemove: (SavedLocation) -> Void
    let onSetHome: (SavedLocation) -> Void
    let onTap: (SavedLocation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(icon: "star.fill", title: "SAVED CITIES", fontColor: fontColor)

            VStack(spacing: 12) {
                ForEach(savedLocations, id: \.name) { location in
                    SavedCityCard(
                        location: location,
                        liveWeather: savedWeatherResponses.first {
                            $0.location.name.lowercased() == location.name.lowercased()
                        },
                        fontColor: fontColor,
                        onRemove: { onRemove(location) },
                        onSetHome: { onSetHome(location) },
                        onTap: { onTap(location) }
                    )
                }
            }
        }
    }
}
struct SavedCityCard: View {
    let location: SavedLocation
    let liveWeather: WeatherResponse?
    let fontColor: Color
    let onRemove: () -> Void
    let onSetHome: () -> Void
    let onTap: () -> Void

    var body: some View {
        GlassCardView {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(fontColor)

                    if let w = liveWeather {
                        Text(w.current.condition.text)
                            .font(.system(size: 13))
                            .foregroundColor(fontColor.opacity(0.65))
                        Text("H:\(Int(w.forecast.forecastday.first?.day.maxtemp_c ?? 0))°  L:\(Int(w.forecast.forecastday.first?.day.mintemp_c ?? 0))°")
                            .font(.system(size: 12))
                            .foregroundColor(fontColor.opacity(0.5))
                    } else {
                        Text(location.country)
                            .font(.system(size: 13))
                            .foregroundColor(fontColor.opacity(0.55))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    if let w = liveWeather {
                        Text("\(Int(w.current.temp_c))°")
                            .font(.system(size: 44, weight: .thin))
                            .foregroundColor(fontColor)
                    }

                    Button {
                        onRemove()
                    } label: {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 18))
                    }
                }
            }
        }
        .modifier(SwipeActionsModifier(
            deleteAction: onRemove,
            setHomeAction: onSetHome
        ))
        .onTapGesture { onTap() }
    }
}
