//
//  WeatherCastApp.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.


import Foundation
import SwiftUI
import CoreLocation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {

    @Published var weatherResponse: WeatherResponse?
    @Published var savedWeatherResponses: [WeatherResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var savedLocations: [SavedLocation] = []
    @Published var isCurrentLocationSaved: Bool = false
    @Published var isConnected: Bool = true
    @Published var locationAuthStatus: CLAuthorizationStatus = .notDetermined
    @Published var showOfflineBanner: Bool = false
    @Published var showConnectedBanner: Bool = false
    private let fetchWeatherUseCase: FetchWeatherUseCase
    private let searchCityUseCase: SearchCityUseCase
    private let saveLocationUseCase: SaveLocationUseCase
    private let deleteLocationUseCase: DeleteLocationUseCase
    private let fetchLocationsUseCase: FetchLocationsUseCase
    private let toggleLocationUseCase: ToggleLocationUseCase
    private let isLocationSavedUseCase: IsLocationSavedUseCase
    private let getLocationUseCase: GetLocationUseCase
    private let getNetworkStatusUseCase: GetNetworkStatusUseCase
    private let defaultCity = "Ismailia"
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchWeatherUseCase: FetchWeatherUseCase,
        searchCityUseCase: SearchCityUseCase,
        saveLocationUseCase: SaveLocationUseCase,
        deleteLocationUseCase: DeleteLocationUseCase,
        fetchLocationsUseCase: FetchLocationsUseCase,
        toggleLocationUseCase: ToggleLocationUseCase,
        isLocationSavedUseCase: IsLocationSavedUseCase,
        getLocationUseCase: GetLocationUseCase,
        getNetworkStatusUseCase: GetNetworkStatusUseCase
    ) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.searchCityUseCase = searchCityUseCase
        self.saveLocationUseCase = saveLocationUseCase
        self.deleteLocationUseCase = deleteLocationUseCase
        self.fetchLocationsUseCase = fetchLocationsUseCase
        self.toggleLocationUseCase = toggleLocationUseCase
        self.isLocationSavedUseCase = isLocationSavedUseCase
        self.getLocationUseCase = getLocationUseCase
        self.getNetworkStatusUseCase = getNetworkStatusUseCase

        self.isConnected = getNetworkStatusUseCase.isConnected
        self.locationAuthStatus = getLocationUseCase.authorizationStatus

        observeUseCases()
    }

    private func observeUseCases() {
        getNetworkStatusUseCase.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                guard let self else { return }
                self.isConnected = connected
                Task { await self.handleNetworkChange(isConnected: connected) }
            }
            .store(in: &cancellables)

        getLocationUseCase.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                self.locationAuthStatus = status
                Task { await self.handleAuthChange(status: status) }
            }
            .store(in: &cancellables)

        getLocationUseCase.$currentLocation
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] location in
                guard let self, self.isConnected else { return }
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
        showOfflineBanner = !isConnected
        await fetchAllSavedWeather()

        guard isConnected else { return }

        if let customCity = UserDefaults.standard.string(forKey: "customDefaultCity") {
             await fetchCustomCityWeather(cityName: customCity)
             return
        }

        switch locationAuthStatus {
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
                showOfflineBanner = false
                showConnectedBanner = true
            }
            await fetchAllSavedWeather()
            if let customCity = UserDefaults.standard.string(forKey: "customDefaultCity") {
                if weatherResponse == nil { await fetchCustomCityWeather(cityName: customCity) }
            } else {
                switch locationAuthStatus {
                case .denied, .restricted:
                    if weatherResponse == nil { await fetchDefaultWeather() }
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
                showConnectedBanner = false
            }
        } else {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                showOfflineBanner = true
                showConnectedBanner = false
            }
        }
    }

    private func handleAuthChange(status: CLAuthorizationStatus) async {
        if UserDefaults.standard.string(forKey: "customDefaultCity") != nil { return }
        switch status {
        case .denied, .restricted:
            if weatherResponse == nil { await fetchDefaultWeather() }
        case .authorizedWhenInUse, .authorizedAlways:
            getLocationUseCase.startUpdatingLocation()
        default: break
        }
    }

    func fetchDefaultWeather() async {
        isLoading = true
        errorMessage = nil
        do {
            weatherResponse = try await searchCityUseCase.execute(query: defaultCity)
            checkIfCurrentLocationSaved()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func setCustomDefaultCity(_ cityName: String) {
        UserDefaults.standard.set(cityName, forKey: "customDefaultCity")
        Task {
            await fetchCustomCityWeather(cityName: cityName)
        }
    }

    func fetchCustomCityWeather(cityName: String) async {
        isLoading = true
        errorMessage = nil
        do {
            weatherResponse = try await searchCityUseCase.execute(query: cityName)
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
            weatherResponse = try await fetchWeatherUseCase.execute(lat: lat, lon: lon)
            checkIfCurrentLocationSaved()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
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
    func toggleCurrentLocation() {
        guard let weather = weatherResponse else { return }
        let location = SavedLocation(
            name: weather.location.name,
            lat: weather.location.lat,
            lon: weather.location.lon,
            country: weather.location.country
        )
        do {
            try toggleLocationUseCase.execute(location)
            checkIfCurrentLocationSaved()
            fetchSavedLocations()
            Task { await fetchAllSavedWeather() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    func toggleLocationFromSearch(location: SavedLocation) {
        do {
            try toggleLocationUseCase.execute(location)
            fetchSavedLocations()
            checkIfCurrentLocationSaved()
            Task { await fetchAllSavedWeather() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    func fetchSavedLocations() {
        do {
            savedLocations = try fetchLocationsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchAllSavedWeather() async {
        fetchSavedLocations()
        guard !savedLocations.isEmpty else {
            savedWeatherResponses = []
            return
        }
        await withTaskGroup(of: (Int, WeatherResponse?).self) { group in
            for (index, location) in savedLocations.enumerated() {
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
            savedWeatherResponses = results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }

    func isLocationSaved(name: String) -> Bool {
        (try? isLocationSavedUseCase.execute(name: name)) ?? false
    }

    private func checkIfCurrentLocationSaved() {
        guard let name = weatherResponse?.location.name else { return }
        isCurrentLocationSaved = isLocationSaved(name: name)
    }
    var backgroundImage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return (hour >= 5 && hour < 18) ? "morning_bg" : "evening_bg"
    }

    var fontColor: Color {
        let hour = Calendar.current.component(.hour, from: Date())
        return (hour >= 5 && hour < 18) ? .black : .white
    }

    func iconURL(for icon: String) -> URL? {
        URL(string: "https:\(icon)")
    }
}
