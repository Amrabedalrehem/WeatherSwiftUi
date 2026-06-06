import SwiftUI
import SwiftUI

struct SearchView: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: SearchViewModel
    @Environment(\.dismiss) var dismiss

    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var searchedWeather: WeatherResponse?
    @State private var searchError: String?
    @State private var animateSuggestions: Bool = false
    @State private var selectedPreviewWeather: WeatherResponse? = nil

    private var currentCondition: String {
        appState.weatherResponse?.current.condition.text ?? ""
    }
    private func checkIfIsDay() -> Bool {
        (appState.weatherResponse?.current.is_day ?? 1) == 1
    }
    private var fontColor: Color { checkIfIsDay() ? .black : .white }

    private var filteredSuggestions: [SavedLocation] {
        searchText.isEmpty
            ? suggestedCities
            : suggestedCities.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.country.lowercased().contains(searchText.lowercased())
            }
    }

    var body: some View {
        ZStack {
            SearchBackground(
                weatherResponse: appState.weatherResponse,
                currentCondition: currentCondition,
                isDay: checkIfIsDay()
            )

            VStack(spacing: 0) {
                SearchHeader(fontColor: fontColor)

                SearchBar(
                    searchText: $searchText,
                    onClear: {
                        withAnimation(.spring()) {
                            searchText = ""
                            searchedWeather = nil
                            searchError = nil
                        }
                    },
                    onSubmit: { performSearch() }
                )
                .padding(.horizontal, 20)

                searchStateView

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        SuggestionsSection(
                            filteredSuggestions: filteredSuggestions,
                            searchText: searchText,
                            animateSuggestions: animateSuggestions,
                            fontColor: fontColor,
                            onCityTap: { city in
                                Task {
                                    if let result = try? await viewModel.searchCity(query: city.name) {
                                        selectedPreviewWeather = result
                                    }
                                }
                            }
                        )
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
    @ViewBuilder
    private var searchStateView: some View {
        if isSearching {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.3)
                .padding(.top, 24)
        } else if let weather = searchedWeather {
            SearchResultCard(
                weather: weather,
                fontColor: fontColor,
                isSaved: appState.savedLocations.contains { $0.name == weather.location.name },
                isHome: appState.weatherResponse?.location.name == weather.location.name,
                onToggleSave: {
                    let location = SavedLocation(
                        name: weather.location.name,
                        lat: weather.location.lat,
                        lon: weather.location.lon,
                        country: weather.location.country
                    )
                    viewModel.toggleLocationFromSearch(location: location)
                    viewModel.fetchSavedLocations()
                },
                onTap: { selectedPreviewWeather = searchedWeather }
            )
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
    }

      private func performSearch() {
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
}
