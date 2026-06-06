//
//  GetNetworkStatusUseCase.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 06/06/2026.
//

 
import Foundation
import Combine

class GetNetworkStatusUseCase: ObservableObject {

    private let networkMonitor: NetworkMonitor

    @Published var isConnected: Bool

    private var cancellables = Set<AnyCancellable>()

    init(networkMonitor: NetworkMonitor) {
        self.networkMonitor = networkMonitor
        self.isConnected = networkMonitor.isConnected

        networkMonitor.$isConnected
            .sink { [weak self] status in
                self?.isConnected = status
            }
            .store(in: &cancellables)
    }
}
