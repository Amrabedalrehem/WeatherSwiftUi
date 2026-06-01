//
//  FetchWeatherUseCase 2.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


class FetchWeatherUseCase {
    
    private let repository: WeatherRepositoryProtocol
    
    init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(lat: Double, lon: Double) async throws -> WeatherResponse {
        return try await repository.fetchWeather(lat: lat, lon: lon)
    }
}