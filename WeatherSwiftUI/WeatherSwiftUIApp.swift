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
 
    let container: ModelContainer = {
        let schema = Schema([SavedLocation.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
 
    @StateObject private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(makeViewModel())
                .environmentObject(locationManager)
                .modelContainer(container)
                .onAppear {
                    locationManager.requestPermission()
                }
        }
    }
    
 
    private func makeViewModel() -> WeatherViewModel {
        
        let context = container.mainContext
        let weatherService = WeatherService()
        let weatherRepo = WeatherRepository(service: weatherService)
        let savedLocationRepo = SavedLocationRepository(modelContext: context)
        let fetchWeatherUseCase = FetchWeatherUseCase(repository: weatherRepo)
        let searchCityUseCase = SearchCityUseCase(repository: weatherRepo)
        let saveLocationUseCase = SaveLocationUseCase(repository: savedLocationRepo)
        let deleteLocationUseCase = DeleteLocationUseCase(repository: savedLocationRepo)
        let fetchLocationsUseCase = FetchLocationsUseCase(repository: savedLocationRepo)
        let toggleLocationUseCase = ToggleLocationUseCase(repository: savedLocationRepo)
        let isLocationSavedUseCase = IsLocationSavedUseCase(repository: savedLocationRepo)
        
        return WeatherViewModel(
            fetchWeatherUseCase: fetchWeatherUseCase,
            searchCityUseCase: searchCityUseCase,
            saveLocationUseCase: saveLocationUseCase,
            deleteLocationUseCase: deleteLocationUseCase,
            fetchLocationsUseCase: fetchLocationsUseCase,
            toggleLocationUseCase: toggleLocationUseCase,
            isLocationSavedUseCase: isLocationSavedUseCase
        )
    }
}
