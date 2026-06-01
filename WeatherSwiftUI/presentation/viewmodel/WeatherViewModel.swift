//
//  WeatherViewModel.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


import Foundation
import SwiftUI

@MainActor
class WeatherViewModel: ObservableObject {
    
    @Published var weatherResponse: WeatherResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var savedLocations: [SavedLocation] = []
    @Published var isCurrentLocationSaved: Bool = false
    private let fetchWeatherUseCase: FetchWeatherUseCase
    private let searchCityUseCase: SearchCityUseCase
    private let saveLocationUseCase: SaveLocationUseCase
    private let deleteLocationUseCase: DeleteLocationUseCase
    private let fetchLocationsUseCase: FetchLocationsUseCase
    private let toggleLocationUseCase: ToggleLocationUseCase
    private let isLocationSavedUseCase: IsLocationSavedUseCase
    private let defaultLat: Double = 30.0444
    private let defaultLon: Double = 31.2357
 
    init(
        fetchWeatherUseCase: FetchWeatherUseCase,
        searchCityUseCase: SearchCityUseCase,
        saveLocationUseCase: SaveLocationUseCase,
        deleteLocationUseCase: DeleteLocationUseCase,
        fetchLocationsUseCase: FetchLocationsUseCase,
        toggleLocationUseCase: ToggleLocationUseCase,
        isLocationSavedUseCase: IsLocationSavedUseCase
    ) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.searchCityUseCase = searchCityUseCase
        self.saveLocationUseCase = saveLocationUseCase
        self.deleteLocationUseCase = deleteLocationUseCase
        self.fetchLocationsUseCase = fetchLocationsUseCase
        self.toggleLocationUseCase = toggleLocationUseCase
        self.isLocationSavedUseCase = isLocationSavedUseCase
    }
    
    func fetchDefaultWeather() async {
        await fetchWeather(lat: defaultLat, lon: defaultLon)
    }
    
      func fetchWeather(lat: Double, lon: Double) async {
        isLoading = true
        errorMessage = nil
        do {
            weatherResponse = try await fetchWeatherUseCase.execute(
                lat: lat,
                lon: lon
            )
            checkIfCurrentLocationSaved()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
   

 
    func searchCity(query: String) async {
        isLoading = true
        errorMessage = nil
        do {
            weatherResponse = try await searchCityUseCase.execute(query: query)
            checkIfCurrentLocationSaved()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
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
    
  
    private func checkIfCurrentLocationSaved() {
        guard let name = weatherResponse?.location.name else { return }
        do {
            isCurrentLocationSaved = try isLocationSavedUseCase.execute(name: name)
        } catch {
            errorMessage = error.localizedDescription
        }
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
        return URL(string: "https:\(icon)")
    }
}
