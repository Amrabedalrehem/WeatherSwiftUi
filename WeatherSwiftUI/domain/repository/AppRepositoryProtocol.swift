//
//  AppRepositoryProtocol.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 03/06/2026.
//

import Foundation

protocol AppRepositoryProtocol {
      func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse
    func searchCity(query: String) async throws -> WeatherResponse
    
     func saveLocation(_ location: SavedLocation) throws
    func deleteLocation(_ location: SavedLocation) throws
    func fetchAllLocations() throws -> [SavedLocation]
    func isLocationSaved(name: String) throws -> Bool
    func toggleLocation(_ location: SavedLocation) throws
}
