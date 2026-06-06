import Foundation
import Combine
import SwiftUI

@MainActor
class ManageCitiesViewModel: ObservableObject {
    let appState: AppState
    private let fetchLocationsUseCase: FetchLocationsUseCase
    private let toggleLocationUseCase: ToggleLocationUseCase
    private let deleteLocationUseCase: DeleteLocationUseCase
    private let searchCityUseCase: SearchCityUseCase
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(appState: AppState,
         fetchLocationsUseCase: FetchLocationsUseCase,
         toggleLocationUseCase: ToggleLocationUseCase,
         deleteLocationUseCase: DeleteLocationUseCase,
         searchCityUseCase: SearchCityUseCase) {
        self.appState = appState
        self.fetchLocationsUseCase = fetchLocationsUseCase
        self.toggleLocationUseCase = toggleLocationUseCase
        self.deleteLocationUseCase = deleteLocationUseCase
        self.searchCityUseCase = searchCityUseCase
    }
    
    func fetchSavedLocations() {
        do {
            appState.savedLocations = try fetchLocationsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func removeLocation(_ location: SavedLocation) {
        do {
            try deleteLocationUseCase.execute(location)
            fetchSavedLocations()
              syncCurrentLocationSavedState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func setCustomDefaultCity(_ cityName: String) {
        UserDefaults.standard.set(cityName, forKey: "customDefaultCity")
        Task {
            await fetchCustomCityWeather(cityName: cityName)
        }
    }
    
    private func fetchCustomCityWeather(cityName: String) async {
        isLoading = true
        errorMessage = nil
        do {
            appState.weatherResponse = try await searchCityUseCase.execute(query: cityName)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func fetchAllSavedWeather() async {
        fetchSavedLocations()
        guard !appState.savedLocations.isEmpty else {
            appState.savedWeatherResponses = []
            return
        }
        await withTaskGroup(of: (Int, WeatherResponse?).self) { group in
            for (index, location) in appState.savedLocations.enumerated() {
                group.addTask { [weak self] in
                    guard let self else { return (index, nil) }
                    do {
                        let response = try await self.searchCityUseCase.execute(query: location.name)
                        return (index, response)
                    } catch {
                        return (index, nil)
                    }
                }
            }
            var results: [(Int, WeatherResponse)] = []
            for await (index, response) in group {
                if let response { results.append((index, response)) }
            }
            appState.savedWeatherResponses = results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }
    
      private func syncCurrentLocationSavedState() {
        guard let currentName = appState.weatherResponse?.location.name else { return }
        appState.isCurrentLocationSaved = appState.savedLocations.contains {
            $0.name.lowercased() == currentName.lowercased()
        }
    }
}
