//
//  ToggleLocationUseCase.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


class ToggleLocationUseCase {
    
    private let repository: SavedLocationRepositoryProtocol
    
    init(repository: SavedLocationRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ location: SavedLocation) throws {
        try repository.toggleLocation(location)
    }
}