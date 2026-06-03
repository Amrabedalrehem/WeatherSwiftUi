//
//  WeatherResponse.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


import Foundation


struct WeatherResponse: Codable, Hashable, Equatable {
    let location: Location
    let current: Current
    let forecast: Forecast
}


struct Location: Codable, Hashable, Equatable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String  
}
 


struct Current: Codable, Hashable, Equatable {
    let temp_c: Double
    let feelslike_c: Double
    let humidity: Int
    let pressure_mb: Double
    let vis_km: Double
    let condition: Condition
    let is_day: Int  
}

struct Condition: Codable, Hashable, Equatable {
    let text: String
    let icon: String
}


struct Forecast: Codable, Hashable, Equatable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable, Hashable {
    var id: String { date }
    let date: String
    let day: Day
    let hour: [Hour]

    static func == (lhs: ForecastDay, rhs: ForecastDay) -> Bool {
        lhs.date == rhs.date
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
}


struct Day: Codable, Hashable, Equatable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let condition: Condition
}

struct Hour: Codable, Hashable, Equatable {
    let time: String
    let temp_c: Double
    let condition: Condition
}
