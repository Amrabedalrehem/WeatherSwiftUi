//
//  FetchWeatherUseCase.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


import Foundation

 class SearchCityUseCase {
    
    private let repository: AppRepositoryProtocol
    
    init(repository: AppRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(query: String) async throws -> WeatherResponse {
        return try await repository.searchCity(query: query)
    }
}
