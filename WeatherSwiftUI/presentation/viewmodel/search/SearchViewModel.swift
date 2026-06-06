import Foundation
import Combine
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    let appState: AppState
    private let searchCityUseCase: SearchCityUseCase
    private let toggleLocationUseCase: ToggleLocationUseCase
    private let fetchLocationsUseCase: FetchLocationsUseCase
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(appState: AppState,
         searchCityUseCase: SearchCityUseCase,
         toggleLocationUseCase: ToggleLocationUseCase,
         fetchLocationsUseCase: FetchLocationsUseCase) {
        self.appState = appState
        self.searchCityUseCase = searchCityUseCase
        self.toggleLocationUseCase = toggleLocationUseCase
        self.fetchLocationsUseCase = fetchLocationsUseCase
    }
    
    func searchCity(query: String) async throws -> WeatherResponse {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            return try await searchCityUseCase.execute(query: query)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func toggleLocationFromSearch(location: SavedLocation) {
        do {
            try toggleLocationUseCase.execute(location)
            fetchSavedLocations()
            syncCurrentLocationSavedState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchSavedLocations() {
        do {
            appState.savedLocations = try fetchLocationsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
      private func syncCurrentLocationSavedState() {
        guard let currentName = appState.weatherResponse?.location.name else { return }
        appState.isCurrentLocationSaved = appState.savedLocations.contains {
            $0.name.lowercased() == currentName.lowercased()
        }
    }
}
