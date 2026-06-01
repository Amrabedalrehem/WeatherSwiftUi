//
//  SavedLocation.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


import Foundation
import SwiftData

@Model
class SavedLocation {
    var name: String
    var lat: Double
    var lon: Double
    var country: String
    
    init(name: String, lat: Double, lon: Double, country: String) {
        self.name = name
        self.lat = lat
        self.lon = lon
        self.country = country
    }
}