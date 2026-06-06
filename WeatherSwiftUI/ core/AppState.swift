import Foundation
import CoreLocation
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var weatherResponse: WeatherResponse?
    @Published var savedWeatherResponses: [WeatherResponse] = []
    @Published var savedLocations: [SavedLocation] = []
    @Published var isCurrentLocationSaved: Bool = false
    @Published var isConnected: Bool = true
    @Published var locationAuthStatus: CLAuthorizationStatus = .notDetermined
    @Published var showOfflineBanner: Bool = false
    @Published var showConnectedBanner: Bool = false
}
