import SwiftUI

struct ContentView: View {

    @EnvironmentObject var viewModel: WeatherViewModel
    @EnvironmentObject var locationManager: LocationManager

    @State private var navigateToSearch: Bool = false
    @State private var searchBarPressed: Bool = false
    @State private var selectedDay: ForecastDay? = nil
    @State private var currentPage: Int = 0

    @State private var isInitialLoad: Bool = true
     private var allWeatherPages: [WeatherResponse] {
        var pages: [WeatherResponse] = []
        if let current = viewModel.weatherResponse {
            pages.append(current)
        }
        pages.append(contentsOf: viewModel.savedWeatherResponses)
        return pages
    }

    private var totalPages: Int {
        allWeatherPages.count
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                 if isInitialLoad
                    || (viewModel.isLoading && allWeatherPages.isEmpty)
                    || (locationManager.authorizationStatus == .notDetermined && allWeatherPages.isEmpty) {

                    ZStack {
                        Color(red: 0.1, green: 0.25, blue: 0.45)
                            .ignoresSafeArea()
                        ProgressView("Loading Weather...")
                            .tint(.white)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
           } else if !allWeatherPages.isEmpty {
                    TabView(selection: $currentPage) {
                        ForEach(Array(allWeatherPages.enumerated()), id: \.offset) { index, weather in
                            WeatherPageView(
                                weather: weather,
                                isCurrentLocation: index == 0 && viewModel.weatherResponse != nil,
                                selectedDay: $selectedDay
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .ignoresSafeArea()
                    .onChange(of: viewModel.savedWeatherResponses.count) { _, _ in
                        let maxPage = allWeatherPages.count - 1
                        if currentPage > maxPage {
                            withAnimation { currentPage = max(0, maxPage) }
                        }
                    }

                  } else if let error = viewModel.errorMessage {
                    ZStack {
                        Color(red: 0.1, green: 0.25, blue: 0.45)
                            .ignoresSafeArea()
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                } else {
                    Color(red: 0.1, green: 0.25, blue: 0.45)
                        .ignoresSafeArea()
                }

                  if !allWeatherPages.isEmpty {
                    VStack(spacing: 12) {
                        if totalPages > 1 {
                            HStack(spacing: 8) {
                                ForEach(0..<totalPages, id: \.self) { index in
                                    if index == 0 {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 8))
                                            .foregroundColor(currentPage == 0 ? .white : .white.opacity(0.4))
                                            .scaleEffect(currentPage == 0 ? 1.3 : 1.0)
                                            .animation(.spring(response: 0.3), value: currentPage)
                                    } else {
                                        Circle()
                                            .fill(currentPage == index ? .white : .white.opacity(0.35))
                                            .frame(width: currentPage == index ? 8 : 6,
                                                   height: currentPage == index ? 8 : 6)
                                            .animation(.spring(response: 0.3), value: currentPage)
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 16)
                            .background(.ultraThinMaterial, in: Capsule())
                        }

                        floatingSearchBar
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
            .navigationDestination(isPresented: $navigateToSearch) {
                SearchView().environmentObject(viewModel)
            }
            .navigationDestination(item: $selectedDay) { day in
                HourlyView(forecastDay: day, fontColor: .white)
            }
             .onAppear {
                Task {
                      await viewModel.fetchAllSavedWeather()
                         let status = locationManager.authorizationStatus
                    if status == .notDetermined {
                        locationManager.requestPermission()
                    } else if status == .denied || status == .restricted {
                        await viewModel.fetchDefaultWeather()
                    } else if status == .authorizedWhenInUse || status == .authorizedAlways {
                        if let location = locationManager.currentLocation {
                            await viewModel.fetchWeather(
                                lat: location.coordinate.latitude,
                                lon: location.coordinate.longitude
                            )
                        } else {
                            locationManager.startUpdatingLocation()
                        }
                    }

                    withAnimation(.easeIn(duration: 0.3)) {
                        isInitialLoad = false
                    }
                }
            }
              .onChange(of: locationManager.authorizationStatus) { _, status in
                Task {
                    if status == .denied || status == .restricted {
                        if viewModel.weatherResponse == nil {
                            await viewModel.fetchDefaultWeather()
                        }
                    } else if status == .authorizedWhenInUse || status == .authorizedAlways {
                        locationManager.startUpdatingLocation()
                    }
                }
            }
              .onChange(of: locationManager.currentLocation) { _, newLocation in
                guard let location = newLocation else { return }
                Task {
                    await viewModel.fetchWeather(
                        lat: location.coordinate.latitude,
                        lon: location.coordinate.longitude
                    )
                    withAnimation {
                        currentPage = 0      }
                }
            }
            .onChange(of: navigateToSearch) { _, isShowing in
                if !isShowing {
                    Task { await viewModel.fetchAllSavedWeather() }
                }
            }
        }
    }

      private var floatingSearchBar: some View {
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                searchBarPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    searchBarPressed = false
                }
                navigateToSearch = true
            }
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.18))
                        .frame(width: 38, height: 38)
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }

                Text("Search city or location...")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.55))

                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.cyan.opacity(0.9))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            .scaleEffect(searchBarPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
