//
//  WeatherRepository.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//

import Foundation

class WeatherRepository: WeatherRepositoryProtocol {
    
    private let service: WeatherService
    
    init(service: WeatherService) {
        self.service = service
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        return try await service.fetchWeather(lat: lat, lon: lon)
    }
    
    func searchCity(query: String) async throws -> WeatherResponse {
        return try await service.searchCity(query: query)
    }
}
