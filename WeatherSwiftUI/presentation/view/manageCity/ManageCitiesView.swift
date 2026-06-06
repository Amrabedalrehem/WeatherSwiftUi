
import SwiftUI

struct ManageCitiesView: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: ManageCitiesViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedPreviewWeather: WeatherResponse? = nil
    @State private var navigateToSearch: Bool = false
    @State private var showRemoveAlert: Bool = false
    @State private var locationToRemove: SavedLocation? = nil
    @State private var showSetHomeAlert: Bool = false
    @State private var locationToSetHome: SavedLocation? = nil

    private var currentCondition: String {
        appState.weatherResponse?.current.condition.text ?? ""
    }
    private func checkIfIsDay() -> Bool {
        (appState.weatherResponse?.current.is_day ?? 1) == 1
    }
    private var fontColor: Color { checkIfIsDay() ? .black : .white }

    var body: some View {
        ZStack {
            ManageCitiesBackground(
                weatherResponse: appState.weatherResponse,
                currentCondition: currentCondition,
                isDay: checkIfIsDay()
            )

            VStack(spacing: 0) {
                ManageCitiesHeader(fontColor: fontColor)

                searchBarButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        if appState.weatherResponse != nil {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionLabel(icon: "house.fill", title: "DEFAULT CITY", fontColor: fontColor)
                                homeCityCard
                            }
                            .padding(.horizontal, 20)
                        }

                        if !appState.savedLocations.isEmpty {
                            SavedCitiesSection(
                                savedLocations: appState.savedLocations,
                                savedWeatherResponses: appState.savedWeatherResponses,
                                fontColor: fontColor,
                                onRemove: { location in
                                    locationToRemove = location
                                    showRemoveAlert = true
                                },
                                onSetHome: { location in
                                    locationToSetHome = location
                                    showSetHomeAlert = true
                                },
                                onTap: { location in
                                    Task {
                                        let liveWeather = appState.savedWeatherResponses.first {
                                            $0.location.name.lowercased() == location.name.lowercased()
                                        }
                                        if let w = liveWeather {
                                            selectedPreviewWeather = w
                                        } else {
                                            }
                                    }
                                }
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .navigationDestination(item: $selectedPreviewWeather) { weather in
            WeatherPreviewView(weather: weather)
        }
        .navigationDestination(isPresented: $navigateToSearch) {
            SearchView()
        }
        .onAppear {
            viewModel.fetchSavedLocations()
            Task { await viewModel.fetchAllSavedWeather() }
        }
        .alert("Remove Favorite?", isPresented: $showRemoveAlert) {
            Button("Remove", role: .destructive) {
                if let location = locationToRemove {
                    withAnimation(.spring()) {
                        viewModel.removeLocation(location)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let location = locationToRemove {
                Text("Are you sure you want to remove \(location.name) from your favorites?")
            }
        }
        .alert("Change Default Location?", isPresented: $showSetHomeAlert) {
            Button("Change") {
                if let location = locationToSetHome {
                    withAnimation(.spring()) {
                        viewModel.setCustomDefaultCity(location.name)
                        viewModel.removeLocation(location)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let location = locationToSetHome {
                Text("Are you sure you want to set \(location.name) as your default location? It will be removed from saved cities.")
            }
        }
    }

    private var searchBarButton: some View {
        Button { navigateToSearch = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 16, weight: .semibold))
                Text("Search city...")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 16))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var homeCityCard: some View {
        Group {
            if let w = appState.weatherResponse {
                GlassCardView {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(w.location.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(fontColor)
                            Text(w.current.condition.text)
                                .font(.system(size: 13))
                                .foregroundColor(fontColor.opacity(0.65))
                            Text("H:\(Int(w.forecast.forecastday.first?.day.maxtemp_c ?? 0))°  L:\(Int(w.forecast.forecastday.first?.day.mintemp_c ?? 0))°")
                                .font(.system(size: 12))
                                .foregroundColor(fontColor.opacity(0.5))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("\(Int(w.current.temp_c))°")
                                .font(.system(size: 44, weight: .thin))
                                .foregroundColor(fontColor)
                            Image(systemName: "house.fill")
                                .foregroundColor(fontColor)
                                .font(.system(size: 18))
                        }
                    }
                }
                .onTapGesture { dismiss() }
            }
        }
    }
}
