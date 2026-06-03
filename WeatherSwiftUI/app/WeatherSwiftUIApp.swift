//
//  WeatherCastApp.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
 

import SwiftUI
import SwiftData

@main
struct WeatherCastApp: App {
       let container: ModelContainer
    
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel: WeatherViewModel
    
    init() {
     let schema = Schema([SavedLocation.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
        let sharedContainer = try ModelContainer(for: schema, configurations: [config])
            self.container = sharedContainer
                let context = sharedContainer.mainContext
            
            let weatherService = WeatherService()
            let weatherRepo = WeatherRepository(service: weatherService)
            let savedLocationRepo = SavedLocationRepository(modelContext: context)
            
            _viewModel = StateObject(wrappedValue: WeatherViewModel(
                fetchWeatherUseCase: FetchWeatherUseCase(repository: weatherRepo),
                searchCityUseCase: SearchCityUseCase(repository: weatherRepo),
                saveLocationUseCase: SaveLocationUseCase(repository: savedLocationRepo),
                deleteLocationUseCase: DeleteLocationUseCase(repository: savedLocationRepo),
                fetchLocationsUseCase: FetchLocationsUseCase(repository: savedLocationRepo),
                toggleLocationUseCase: ToggleLocationUseCase(repository: savedLocationRepo),
                isLocationSavedUseCase: IsLocationSavedUseCase(repository: savedLocationRepo)
            ))
            
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)
                .environmentObject(locationManager)
                .modelContainer(container)
                .preferredColorScheme(.dark)
                .onAppear {
                    locationManager.requestPermission()
                }
        }
    }
}
 struct RootView: View {
    @State private var splashDone: Bool = false

    var body: some View {
        ZStack {
            ContentView()
                .opacity(splashDone ? 1 : 0)

            if !splashDone {
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        splashDone = true
                    }
                }
                .transition(.opacity)
            }
        }
    }
}
