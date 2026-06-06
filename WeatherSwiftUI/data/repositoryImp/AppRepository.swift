//
//  AppRepository.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 03/06/2026.
//

import Foundation
import SwiftData

class AppRepository: AppRepositoryProtocol {
    
    private let service: WeatherService
    private let modelContext: ModelContext
    
    init(service: WeatherService, modelContext: ModelContext) {
        self.service = service
        self.modelContext = modelContext
    }
    
      func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        return try await service.fetchWeather(lat: lat, lon: lon)
    }
    
    func searchCity(query: String) async throws -> WeatherResponse {
        return try await service.searchCity(query: query)
    }
      func saveLocation(_ location: SavedLocation) throws {
        modelContext.insert(location)
        try modelContext.save()
    }
    
    func deleteLocation(_ location: SavedLocation) throws {
        modelContext.delete(location)
        try modelContext.save()
    }
    
    func fetchAllLocations() throws -> [SavedLocation] {
        let descriptor = FetchDescriptor<SavedLocation>()
        return try modelContext.fetch(descriptor)
    }
    
    func isLocationSaved(name: String) throws -> Bool {
        let descriptor = FetchDescriptor<SavedLocation>()
        let results = try modelContext.fetch(descriptor)
        return results.contains { $0.name == name }
    }

    func toggleLocation(_ location: SavedLocation) throws {
        let descriptor = FetchDescriptor<SavedLocation>()
        let results = try modelContext.fetch(descriptor)
        
        if let existing = results.first(where: { $0.name == location.name }) {
             modelContext.delete(existing)
        } else {
                let newLocation = SavedLocation(
                name: location.name,
                lat: location.lat,
                lon: location.lon,
                country: location.country
            )
            modelContext.insert(newLocation)
        }
        try modelContext.save()
    }
}
