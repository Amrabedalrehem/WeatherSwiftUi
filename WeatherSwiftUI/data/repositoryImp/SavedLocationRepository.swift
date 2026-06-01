//
//  SavedLocationRepository.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//

import Foundation
import SwiftData

class SavedLocationRepository: SavedLocationRepositoryProtocol {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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
            modelContext.insert(location)
        }
        try modelContext.save()
    }
}
