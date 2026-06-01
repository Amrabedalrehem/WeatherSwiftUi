//
//  FetchLocationsUseCase.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//




class FetchLocationsUseCase {
    
    private let repository: SavedLocationRepositoryProtocol
    
    init(repository: SavedLocationRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() throws -> [SavedLocation] {
        return try repository.fetchAllLocations()
    }
}