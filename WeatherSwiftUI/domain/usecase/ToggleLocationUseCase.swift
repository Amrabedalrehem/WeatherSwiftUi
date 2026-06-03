//
//  ToggleLocationUseCase.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


class ToggleLocationUseCase {
    
    private let repository: AppRepositoryProtocol
    
    init(repository: AppRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ location: SavedLocation) throws {
        try repository.toggleLocation(location)
    }
}