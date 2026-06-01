//
//  WeatherRepositoryProtocol.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


import Foundation


protocol WeatherRepositoryProtocol {
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse
    func searchCity(query: String) async throws -> WeatherResponse
}
