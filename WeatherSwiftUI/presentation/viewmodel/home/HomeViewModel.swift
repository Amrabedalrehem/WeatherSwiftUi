import Foundation
import Combine
import CoreLocation
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    
    private let appState: AppState
    private let fetchWeatherUseCase: FetchWeatherUseCase
    private let searchCityUseCase: SearchCityUseCase
    private let fetchLocationsUseCase: FetchLocationsUseCase
    private let getLocationUseCase: GetLocationUseCase
    private let getNetworkStatusUseCase: GetNetworkStatusUseCase
    private let isLocationSavedUseCase: IsLocationSavedUseCase
    
    private let defaultCity = "Ismailia"
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(appState: AppState,
         fetchWeatherUseCase: FetchWeatherUseCase,
         searchCityUseCase: SearchCityUseCase,
         fetchLocationsUseCase: FetchLocationsUseCase,
         getLocationUseCase: GetLocationUseCase,
         getNetworkStatusUseCase: GetNetworkStatusUseCase,
         isLocationSavedUseCase: IsLocationSavedUseCase) {
        self.appState = appState
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.searchCityUseCase = searchCityUseCase
        self.fetchLocationsUseCase = fetchLocationsUseCase
        self.getLocationUseCase = getLocationUseCase
        self.getNetworkStatusUseCase = getNetworkStatusUseCase
        self.isLocationSavedUseCase = isLocationSavedUseCase
        
        observeUseCases()
    }
    
    private func observeUseCases() {
        getNetworkStatusUseCase.$isConnected
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                guard let self else { return }
                self.appState.isConnected = connected
                Task { await self.handleNetworkChange(isConnected: connected) }
            }
            .store(in: &cancellables)
        
        getLocationUseCase.$authorizationStatus
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                self.appState.locationAuthStatus = status
                Task { await self.handleAuthChange(status: status) }
            }
            .store(in: &cancellables)
        
        getLocationUseCase.$currentLocation
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] location in
                guard let self, self.appState.isConnected else { return }
                if UserDefaults.standard.string(forKey: "customDefaultCity") == nil {
                    Task {
                        await self.fetchWeather(
                            lat: location.coordinate.latitude,
                            lon: location.coordinate.longitude
                        )
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func onAppear() async {
        appState.isConnected = getNetworkStatusUseCase.isConnected
        appState.locationAuthStatus = getLocationUseCase.authorizationStatus
        appState.showOfflineBanner = !appState.isConnected
        
        await fetchAllSavedWeather()
        
        guard appState.isConnected else { return }
        
        if let customCity = UserDefaults.standard.string(forKey: "customDefaultCity") {
             await fetchCustomCityWeather(cityName: customCity)
             return
        }
        
        switch appState.locationAuthStatus {
        case .notDetermined:
            getLocationUseCase.requestPermission()
        case .denied, .restricted:
            await fetchDefaultWeather()
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = getLocationUseCase.currentLocation {
                await fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            } else {
                getLocationUseCase.startUpdatingLocation()
            }
        @unknown default:
            break
        }
    }
    
    private func handleNetworkChange(isConnected: Bool) async {
        if isConnected {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                appState.showOfflineBanner = false
                appState.showConnectedBanner = true
            }
            await fetchAllSavedWeather()
            if let customCity = UserDefaults.standard.string(forKey: "customDefaultCity") {
                if appState.weatherResponse == nil { await fetchCustomCityWeather(cityName: customCity) }
            } else {
                switch appState.locationAuthStatus {
                case .denied, .restricted:
                    if appState.weatherResponse == nil { await fetchDefaultWeather() }
                case .authorizedWhenInUse, .authorizedAlways:
                    if let location = getLocationUseCase.currentLocation {
                        await fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                    } else {
                        getLocationUseCase.startUpdatingLocation()
                    }
                default: break
                }
            }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                appState.showConnectedBanner = false
            }
        } else {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                appState.showOfflineBanner = true
                appState.showConnectedBanner = false
            }
        }
    }
    
    private func handleAuthChange(status: CLAuthorizationStatus) async {
        if UserDefaults.standard.string(forKey: "customDefaultCity") != nil { return }
        switch status {
        case .denied, .restricted:
            if appState.weatherResponse == nil { await fetchDefaultWeather() }
        case .authorizedWhenInUse, .authorizedAlways:
            getLocationUseCase.startUpdatingLocation()
        default: break
        }
    }
    
    func fetchDefaultWeather() async {
        isLoading = true
        errorMessage = nil
        do {
            appState.weatherResponse = try await searchCityUseCase.execute(query: defaultCity)
            checkIfCurrentLocationSaved()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func fetchCustomCityWeather(cityName: String) async {
        isLoading = true
        errorMessage = nil
        do {
            appState.weatherResponse = try await searchCityUseCase.execute(query: cityName)
            checkIfCurrentLocationSaved()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func fetchWeather(lat: Double, lon: Double) async {
        isLoading = true
        errorMessage = nil
        do {
            appState.weatherResponse = try await fetchWeatherUseCase.execute(lat: lat, lon: lon)
            checkIfCurrentLocationSaved()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func fetchAllSavedWeather() async {
        do {
            appState.savedLocations = try fetchLocationsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        
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
    
    func isLocationSaved(name: String) -> Bool {
        (try? isLocationSavedUseCase.execute(name: name)) ?? false
    }
    
    private func checkIfCurrentLocationSaved() {
        guard let name = appState.weatherResponse?.location.name else { return }
        appState.isCurrentLocationSaved = isLocationSaved(name: name)
    }
}
