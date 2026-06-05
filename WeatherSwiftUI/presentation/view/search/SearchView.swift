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
        return weather.current.is_day == 1
    }

    private var fontColor: Color { checkIfIsDay() ? .black : .white }

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

            Color.black.opacity(checkIfIsDay() ? 0.15 : 0.35)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                
                // MARK: - Header
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

                    Color.clear
                        .frame(width: 80, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 12)
      searchBar
                    .padding(.horizontal, 20)
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

                    Button {
                        let location = SavedLocation(
                            name: weather.location.name,
                            lat: weather.location.lat,
                            lon: weather.location.lon,
                            country: weather.location.country
                        )
                        viewModel.toggleLocationFromSearch(location: location)
                        viewModel.fetchSavedLocations()
                    } label: {
                        Image(
                            systemName: isSaved(weather.location.name) ?
                            "star.fill" : "star"
                        )
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

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "globe.americas.fill")
                    .foregroundColor(.cyan.opacity(0.9))
                    .font(.system(size: 12))
                Text(searchText.isEmpty ? "POPULAR CITIES" : "RESULTS")
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
                    Text("No cities found")
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
                        .onTapGesture {
                            Task {
                                do {
                                    let result = try await viewModel.searchCity(
                                        query: city.name
                                    )
                                    selectedPreviewWeather = result
                                } catch {}
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
