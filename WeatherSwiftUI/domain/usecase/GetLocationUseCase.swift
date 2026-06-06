//
 
//
//  Created by JETSMobileLabMini2 on 06/06/2026.
//


 
import Foundation
import CoreLocation
import Combine

class GetLocationUseCase: ObservableObject {

    private let locationManager: LocationManager

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        self.authorizationStatus = locationManager.authorizationStatus

        locationManager.$currentLocation
            .sink { [weak self] location in
                self?.currentLocation = location
            }
            .store(in: &cancellables)

        locationManager.$authorizationStatus
            .sink { [weak self] status in
                self?.authorizationStatus = status
            }
            .store(in: &cancellables)

        locationManager.$errorMessage
            .sink { [weak self] error in
                self?.errorMessage = error
            }
            .store(in: &cancellables)
    }

    func requestPermission() {
        locationManager.requestPermission()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}
