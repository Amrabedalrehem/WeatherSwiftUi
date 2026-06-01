//
//  WeatherResponse.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


import Foundation


struct WeatherResponse: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast
}


struct Location: Codable {
    let name: String
    let lat: Double
    let lon: Double
}


struct Current: Codable {
    let temp_c: Double
    let feelslike_c: Double
    let humidity: Int
    let pressure_mb: Double
    let vis_km: Double
    let condition: Condition
}

struct Condition: Codable {
    let text: String
    let icon: String
}


struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let day: Day
    let hour: [Hour]
}


struct Day: Codable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let condition: Condition
}

struct Hour: Codable {
    let time: String
    let temp_c: Double
    let condition: Condition
}
