//
//  WeatherService.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


import Foundation

class WeatherService {
    
    static let shared = WeatherService()
    private let apiKey = "534dcb6811f74a81b6b84539260106"
    private let baseURL = "https://api.weatherapi.com/v1/forecast.json"
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        let urlString = "\(baseURL)?key=\(apiKey)&q=\(lat),\(lon)&days=3&aqi=no&alerts=no"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(WeatherResponse.self, from: data)
        return response
    }
    
    func searchCity(query: String) async throws -> WeatherResponse {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)?key=\(apiKey)&q=\(encoded)&days=3&aqi=no&alerts=no"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(WeatherResponse.self, from: data)
        return response
    }
}