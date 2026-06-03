
//
//   SearchView.swift
//   WeatherSwiftUI
//
//   Created by JETSMobileLabMini2 on 02/06/2026.
//

import SwiftUI

struct SearchView: View {

    @EnvironmentObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss

    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var searchedWeather: WeatherResponse?
    @State private var searchError: String?
    @State private var animateSuggestions: Bool = false
    @State private var selectedPreviewWeather: WeatherResponse? = nil
    private var currentCondition: String {
        viewModel.weatherResponse?.current.condition.text ?? ""
    }

    private func checkIfIsDay() -> Bool {
        guard let weather = viewModel.weatherResponse else { return true }
        return !weather.current.condition.icon.lowercased().contains("night")
    }

       private var filteredSuggestions: [SavedLocation] {
        if searchText.isEmpty {
            return suggestedCities
        } else {
            return suggestedCities.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.country.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        ZStack {
               if viewModel.weatherResponse != nil {
                VideoBackgroundView(
                    condition: currentCondition,
                    isDay: checkIfIsDay()
                )
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

              Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                  HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Home")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }

                    Spacer()

                    Text("Search")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                       Color.clear
                        .frame(width: 80, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 12)

                searchBar
                    .padding(.horizontal, 20)
                    .padding(.top, 0)

                if isSearching {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.3)
                        .padding(.top, 24)
                } else if let weather = searchedWeather {
                    searchResultView(weather: weather)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else if let error = searchError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 15, weight: .medium))
                        .padding(.top, 20)
                        .transition(.opacity)
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        if !viewModel.savedLocations.isEmpty {
                            savedLocationsSection
                                .padding(.horizontal, 20)
                        }
     suggestionsSection
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                    }
                    .padding(.top, 20)
                }
                .animation(.easeInOut(duration: 0.3), value: searchText)
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .navigationDestination(item: $selectedPreviewWeather) { weather in
            WeatherPreviewView(weather: weather)
        }
        .onAppear {
            viewModel.fetchSavedLocations()
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateSuggestions = true
            }
        }
    }
   private var searchBar: some View {
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
            .onSubmit { searchCity() }

            if !searchText.isEmpty {
                Button {
                    withAnimation(.spring()) {
                        searchText = ""
                        searchedWeather = nil
                        searchError = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 18))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.3), lineWidth: 1)
        )
    }
   private func searchResultView(weather: WeatherResponse) -> some View {
        GlassCardView {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 14))
                        Text(weather.location.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text(weather.location.country)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.65))

                    Text(weather.current.condition.text)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.65))
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(Int(weather.current.temp_c))°")
                        .font(.system(size: 40, weight: .thin))
                        .foregroundColor(.white)

                    Button {
                        let location = SavedLocation(
                            name: weather.location.name,
                            lat: weather.location.lat,
                            lon: weather.location.lon,
                            country: weather.location.country
                        )
                        viewModel.toggleLocationFromSearch(location: location)
                    } label: {
                        Image(systemName: isSaved(weather.location.name) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.system(size: 20))
                    }
                }
            }
        }
        .onTapGesture {
            selectedPreviewWeather = searchedWeather
        }
    }

      private var savedLocationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 11))
                Text("SAVED LOCATIONS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.75))
            }

            VStack(spacing: 10) {
                ForEach(viewModel.savedLocations, id: \.name) { location in
                    SavedLocationRowView(location: location)
                        .onTapGesture {
                            Task {
                                do {
                                    let result = try await viewModel.searchCity(query: location.name)
                                    selectedPreviewWeather = result
                                } catch {
                                                    }
                            }
                        }
                }
            }
        }
    }
   private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "globe.americas.fill")
                    .foregroundColor(.cyan.opacity(0.9))
                    .font(.system(size: 12))
                Text(searchText.isEmpty ? "SUGGESTED CITIES" : "RESULTS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.75))

                Spacer()

                Text("\(filteredSuggestions.count) cities")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.45))
            }

            if filteredSuggestions.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.3))
                    Text("No cities found")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(Array(filteredSuggestions.prefix(20).enumerated()), id: \.element.name) { index, city in
                        SuggestionCityCard(
                            city: city,
                            delay: Double(index) * 0.04,
                            animate: animateSuggestions
                        )
                        .onTapGesture {
                            Task {
                                do {
                                    let result = try await viewModel.searchCity(query: city.name)
                                    selectedPreviewWeather = result
                                } catch {
                                                }
                            }
                        }
                    }
                }
            }
        }
    }

      private func searchCity() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        searchError = nil
        searchedWeather = nil

        Task {
            do {
                let result = try await viewModel.searchCity(query: searchText)
                await MainActor.run {
                    withAnimation(.spring()) {
                        searchedWeather = result
                        isSearching = false
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation {
                        searchError = "City not found!"
                        isSearching = false
                    }
                }
            }
        }
    }

    private func isSaved(_ name: String) -> Bool {
        viewModel.savedLocations.contains { $0.name == name }
    }
}
struct SuggestionCityCard: View {
    let city: SavedLocation
    let delay: Double
    let animate: Bool

      private var regionColor: (Color, Color) {
        let country = city.country.lowercased()
        if ["egypt", "morocco", "nigeria", "kenya", "south africa", "tunisia"].contains(country) {
            return (Color(red: 0.9, green: 0.5, blue: 0.1), Color(red: 0.7, green: 0.3, blue: 0.05))
        } else if ["united arab emirates", "saudi arabia", "kuwait", "qatar", "lebanon", "jordan", "iraq", "oman"].contains(country) {
            return (Color(red: 0.2, green: 0.7, blue: 0.9), Color(red: 0.05, green: 0.45, blue: 0.7))
        } else if ["united kingdom", "france", "germany", "italy", "spain", "netherlands", "austria", "turkey", "russia"].contains(country) {
            return (Color(red: 0.5, green: 0.3, blue: 0.95), Color(red: 0.3, green: 0.1, blue: 0.75))
        } else if ["japan", "china", "south korea", "singapore", "thailand", "india", "pakistan", "bangladesh"].contains(country) {
            return (Color(red: 0.9, green: 0.25, blue: 0.45), Color(red: 0.65, green: 0.05, blue: 0.25))
        } else if ["united states", "canada", "mexico", "brazil", "argentina"].contains(country) {
            return (Color(red: 0.1, green: 0.75, blue: 0.55), Color(red: 0.02, green: 0.5, blue: 0.35))
        } else {
            return (Color(red: 0.3, green: 0.6, blue: 0.95), Color(red: 0.1, green: 0.35, blue: 0.7))
        }
    }

    private var flagEmoji: String {
        let country = city.country.lowercased()
        let flags: [String: String] = [
            "egypt": "🇪🇬", "morocco": "🇲🇦", "nigeria": "🇳🇬",
            "kenya": "🇰🇪", "south africa": "🇿🇦", "tunisia": "🇹🇳",
            "united arab emirates": "🇦🇪", "saudi arabia": "🇸🇦",
            "kuwait": "🇰🇼", "qatar": "🇶🇦", "lebanon": "🇱🇧",
            "jordan": "🇯🇴", "iraq": "🇮🇶", "oman": "🇴🇲",
            "united kingdom": "🇬🇧", "france": "🇫🇷", "germany": "🇩🇪",
            "italy": "🇮🇹", "spain": "🇪🇸", "netherlands": "🇳🇱",
            "austria": "🇦🇹", "turkey": "🇹🇷", "russia": "🇷🇺",
            "japan": "🇯🇵", "china": "🇨🇳", "south korea": "🇰🇷",
            "singapore": "🇸🇬", "thailand": "🇹🇭", "india": "🇮🇳",
            "pakistan": "🇵🇰", "bangladesh": "🇧🇩",
            "united states": "🇺🇸", "canada": "🇨🇦", "mexico": "🇲🇽",
            "brazil": "🇧🇷", "argentina": "🇦🇷",
            "australia": "🇦🇺"
        ]
        return flags[country] ?? "🌍"
    }

    var body: some View {
        let colors = regionColor
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [colors.0.opacity(0.55), colors.1.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(flagEmoji)
                    .font(.system(size: 28))

                Spacer()

                Text(city.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(city.country)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            .padding(14)
        }
        .frame(height: 110)
        .scaleEffect(animate ? 1 : 0.85)
        .opacity(animate ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay), value: animate)
        .shadow(color: colors.1.opacity(0.4), radius: 8, x: 0, y: 4)
    }
}
