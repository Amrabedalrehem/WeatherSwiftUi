//
//  SearchResultCard.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 06/06/2026.
//


import SwiftUI

 
struct SearchResultCard: View {
    let weather: WeatherResponse
    let fontColor: Color
    let isSaved: Bool
    let isHome: Bool
    let onToggleSave: () -> Void
    let onTap: () -> Void

    var body: some View {
        GlassCardView {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(fontColor.opacity(0.8))
                            .font(.system(size: 14))
                        Text(weather.location.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(fontColor)
                    }
                    Text(weather.location.country)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(fontColor.opacity(0.65))
                    Text(weather.current.condition.text)
                        .font(.system(size: 13))
                        .foregroundColor(fontColor.opacity(0.65))
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(Int(weather.current.temp_c))°")
                        .font(.system(size: 40, weight: .thin))
                        .foregroundColor(fontColor)

                    if !isHome {
                        AnimatedStarButton(
                            isSaved: isSaved,
                            fontColor: fontColor,
                            size: 20,
                            action: onToggleSave
                        )
                    } else {
                        Image(systemName: "house.fill")
                            .foregroundColor(fontColor.opacity(0.8))
                            .font(.system(size: 16))
                            .padding(.top, 4)
                    }
                }
            }
        }
        .onTapGesture { onTap() }
    }
}
struct SuggestionsSection: View {
    let filteredSuggestions: [SavedLocation]
    let searchText: String
    let animateSuggestions: Bool
    let fontColor: Color
    let onCityTap: (SavedLocation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "globe.americas.fill")
                    .foregroundColor(.cyan.opacity(0.9))
                    .font(.system(size: 12))
                Text(searchText.isEmpty ? "POPULAR CITIES" : "SUGGESTIONS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(fontColor.opacity(0.75))
                Spacer()
                Text("\(filteredSuggestions.count) cities")
                    .font(.system(size: 11))
                    .foregroundColor(fontColor.opacity(0.45))
            }

            if filteredSuggestions.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(fontColor.opacity(0.3))
                    Text("No suggestions found")
                        .font(.system(size: 15))
                        .foregroundColor(fontColor.opacity(0.45))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                FlowLayout(spacing: 10) {
                    ForEach(
                        Array(filteredSuggestions.prefix(30).enumerated()),
                        id: \.element.name
                    ) { index, city in
                        CityChipView(
                            city: city,
                            delay: Double(index) * 0.04,
                            animate: animateSuggestions,
                            fontColor: fontColor
                        )
                        .onTapGesture { onCityTap(city) }
                    }
                }
            }
        }
    }
}
