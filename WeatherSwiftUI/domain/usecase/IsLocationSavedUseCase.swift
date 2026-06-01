//
//  IsLocationSavedUseCase.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


class IsLocationSavedUseCase {
    
    private let repository: SavedLocationRepositoryProtocol
    
    init(repository: SavedLocationRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(name: String) throws -> Bool {
        return try repository.isLocationSaved(name: name)
    }
}