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
    @StateObject private var viewModel: WeatherViewModel

    init() {
        let schema = Schema([SavedLocation.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let sharedContainer = try ModelContainer(for: schema, configurations: [config])
            self.container = sharedContainer
            let context = sharedContainer.mainContext

            let weatherService = WeatherService()
            let appRepo = AppRepository(service: weatherService, modelContext: context)
            let locationManager = LocationManager()
            let networkMonitor = NetworkMonitor()
            let getLocationUseCase = GetLocationUseCase(locationManager: locationManager)
            let getNetworkStatusUseCase = GetNetworkStatusUseCase(networkMonitor: networkMonitor)

            _viewModel = StateObject(wrappedValue: WeatherViewModel(
                fetchWeatherUseCase: FetchWeatherUseCase(repository: appRepo),
                searchCityUseCase: SearchCityUseCase(repository: appRepo),
                saveLocationUseCase: SaveLocationUseCase(repository: appRepo),
                deleteLocationUseCase: DeleteLocationUseCase(repository: appRepo),
                fetchLocationsUseCase: FetchLocationsUseCase(repository: appRepo),
                toggleLocationUseCase: ToggleLocationUseCase(repository: appRepo),
                isLocationSavedUseCase: IsLocationSavedUseCase(repository: appRepo),
                getLocationUseCase: getLocationUseCase,
                getNetworkStatusUseCase: getNetworkStatusUseCase
            ))
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)                  .modelContainer(container)
                .preferredColorScheme(.dark)
                .onAppear {
                    Task { await viewModel.onAppear() }
                }
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
