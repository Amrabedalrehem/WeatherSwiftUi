//
//  SavedLocationRepositoryProtocol.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


import Foundation

protocol SavedLocationRepositoryProtocol {
    func saveLocation(_ location: SavedLocation) throws
    func deleteLocation(_ location: SavedLocation) throws
    func fetchAllLocations() throws -> [SavedLocation]
    func isLocationSaved(name: String) throws -> Bool
    func toggleLocation(_ location: SavedLocation) throws
}
