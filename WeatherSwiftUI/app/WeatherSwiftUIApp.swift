//
//  WeatherCastApp.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//
 

import SwiftUI
import SwiftData

@main
struct WeatherCastApp: App {
    let container: ModelContainer
    @StateObject private var appState: AppState
    @StateObject private var contentViewModel: ContentViewModel
    @StateObject private var searchViewModel: SearchViewModel
    @StateObject private var manageCitiesViewModel: ManageCitiesViewModel

    init() {
        let schema = Schema([SavedLocation.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let sharedContainer = try ModelContainer(for: schema, configurations: [config])
            self.container = sharedContainer
            let context = sharedContainer.mainContext
            
            let initialState = AppState()
            _appState = StateObject(wrappedValue: initialState)
            
            let weatherService = WeatherService()
            let appRepo = AppRepository(service: weatherService, modelContext: context)
            let locationManager = LocationManager()
            let networkMonitor = NetworkMonitor()
            
            let getLocationUseCase = GetLocationUseCase(locationManager: locationManager)
            let getNetworkStatusUseCase = GetNetworkStatusUseCase(networkMonitor: networkMonitor)
            let fetchWeatherUseCase = FetchWeatherUseCase(repository: appRepo)
            let searchCityUseCase = SearchCityUseCase(repository: appRepo)
            let saveLocationUseCase = SaveLocationUseCase(repository: appRepo)
            let deleteLocationUseCase = DeleteLocationUseCase(repository: appRepo)
            let fetchLocationsUseCase = FetchLocationsUseCase(repository: appRepo)
            let toggleLocationUseCase = ToggleLocationUseCase(repository: appRepo)
            let isLocationSavedUseCase = IsLocationSavedUseCase(repository: appRepo)
            
            _contentViewModel = StateObject(wrappedValue: ContentViewModel(
                appState: initialState,
                fetchWeatherUseCase: fetchWeatherUseCase,
                searchCityUseCase: searchCityUseCase,
                fetchLocationsUseCase: fetchLocationsUseCase,
                getLocationUseCase: getLocationUseCase,
                getNetworkStatusUseCase: getNetworkStatusUseCase,
                isLocationSavedUseCase: isLocationSavedUseCase
            ))
            
            _searchViewModel = StateObject(wrappedValue: SearchViewModel(
                appState: initialState,
                searchCityUseCase: searchCityUseCase,
                toggleLocationUseCase: toggleLocationUseCase,
                fetchLocationsUseCase: fetchLocationsUseCase
            ))
            
            _manageCitiesViewModel = StateObject(wrappedValue: ManageCitiesViewModel(
                appState: initialState,
                fetchLocationsUseCase: fetchLocationsUseCase,
                toggleLocationUseCase: toggleLocationUseCase,
                deleteLocationUseCase: deleteLocationUseCase,
                searchCityUseCase: searchCityUseCase
            ))
            
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(contentViewModel)
                .environmentObject(searchViewModel)
                .environmentObject(manageCitiesViewModel)
                .modelContainer(container)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @State private var splashDone = false

    var body: some View {
        ZStack {
            ContentView().opacity(splashDone ? 1 : 0)
            if !splashDone {
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.6)) { splashDone = true }
                }
                .transition(.opacity)
            }
        }
    }
}
