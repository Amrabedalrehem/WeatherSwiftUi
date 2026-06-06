import SwiftUI

struct ContentView: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var navigateToManage: Bool = false
    @State private var selectedDay: ForecastDay? = nil
    @State private var currentPage: Int = 0
    @State private var showShareSheet: Bool = false
    @State private var isInitialLoad: Bool = true

    private var allWeatherPages: [WeatherResponse] {
        var pages: [WeatherResponse] = []
        if let current = appState.weatherResponse { pages.append(current) }
        pages.append(contentsOf: appState.savedWeatherResponses)
        return pages
    }

    private var totalPages: Int { allWeatherPages.count }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ZStack(alignment: .bottom) {
                    mainContentStateView
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

                            HStack(spacing: 20) {
                                if currentWeather != nil {
                                    Button { showShareSheet = true } label: {
                                        ZStack {
                                            Circle().fill(.ultraThinMaterial).frame(width: 52, height: 52)
                                            Circle().stroke(.white.opacity(0.25), lineWidth: 1).frame(width: 52, height: 52)
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                                    }
                                }
                                Spacer()
                                Button { navigateToManage = true } label: {
                                    ZStack {
                                        Circle().fill(.ultraThinMaterial)
                                        Circle().stroke(.white.opacity(0.25), lineWidth: 1)
                                        Image(systemName: "plus")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 52, height: 52)
                                    .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                                }
                            }
                            .padding(.horizontal, 30)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
              if appState.showOfflineBanner {
                    networkBanner(icon: "wifi.slash", message: "No Internet • Showing cached data", color: .red)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(999)
                }
                if appState.showConnectedBanner {
                    networkBanner(icon: "wifi", message: "Back Online • Refreshing…", color: .green)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(998)
                }
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
            .navigationDestination(isPresented: $navigateToManage) {
                ManageCitiesView()
            }
            .navigationDestination(item: $selectedDay) { day in
                HourlyView(
                    forecastDay: day,
                    isDay: currentPage < allWeatherPages.count
                        ? allWeatherPages[currentPage].current.is_day == 1
                        : true
                )
            }
            .onAppear {
                Task {
                    await viewModel.onAppear()
                    withAnimation(.easeIn(duration: 0.3)) { isInitialLoad = false }
                }
            }
            .onChange(of: navigateToManage) { _, isShowing in
                if !isShowing { Task { await viewModel.fetchAllSavedWeather() } }
            }
            .onChange(of: appState.savedLocations.count) { _, _ in
                 let savedNames = Set(appState.savedLocations.map { $0.name.lowercased() })
                let staleCount = appState.savedWeatherResponses.filter { response in
                    !savedNames.contains(response.location.name.lowercased())
                }.count

                if staleCount > 0 {
                    let newTotal = (appState.weatherResponse != nil ? 1 : 0)
                        + appState.savedWeatherResponses.count - staleCount
                    if currentPage >= newTotal {
                        currentPage = max(0, newTotal - 1)
                    }
                    withAnimation {
                        appState.savedWeatherResponses.removeAll { response in
                            !savedNames.contains(response.location.name.lowercased())
                        }
                    }
                }
            }
            .onChange(of: appState.savedWeatherResponses.count) { _, _ in
                  let maxPage = allWeatherPages.count - 1
                if currentPage > maxPage {
                    withAnimation { currentPage = max(0, maxPage) }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let weather = currentWeather {
                    ShareSheet(activityItems: [shareText(for: weather)])
                        .presentationDetents([.medium, .large])
                }
            }
        }
    }
 
    @ViewBuilder
    private var mainContentStateView: some View {
        if isInitialLoad
            || (viewModel.isLoading && allWeatherPages.isEmpty)
            || (appState.locationAuthStatus == .notDetermined && allWeatherPages.isEmpty) {
            ZStack {
                Color(red: 0.1, green: 0.25, blue: 0.45).ignoresSafeArea()
                ProgressView("Loading Weather...")
                    .tint(.white).foregroundColor(.white).font(.headline)
            }
        } else if !allWeatherPages.isEmpty {
            TabView(selection: $currentPage) {
                ForEach(Array(allWeatherPages.enumerated()), id: \.offset) { index, weather in
                    WeatherPageView(
                        weather: weather,
                        isCurrentLocation: index == 0 && appState.weatherResponse != nil,
                        selectedDay: $selectedDay
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        } else if let error = viewModel.errorMessage {
            ZStack {
                Color(red: 0.1, green: 0.25, blue: 0.45).ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50)).foregroundColor(.red)
                    Text("Error: \(error)").foregroundColor(.red).multilineTextAlignment(.center)
                }
                .padding()
            }
        } else {
            Color(red: 0.1, green: 0.25, blue: 0.45).ignoresSafeArea()
        }
    }
    private var currentWeather: WeatherResponse? {
        guard currentPage < allWeatherPages.count else { return nil }
        return allWeatherPages[currentPage]
    }

    private func shareText(for weather: WeatherResponse) -> String {
        let temp = Int(weather.current.temp_c)
        let city = weather.location.name
        let cond = weather.current.condition.text
        let hi   = Int(weather.forecast.forecastday.first?.day.maxtemp_c ?? 0)
        let lo   = Int(weather.forecast.forecastday.first?.day.mintemp_c ?? 0)
        return """
        🌤 Weather in \(city)
        🌡 \(temp)°C — \(cond)
        ↑ H: \(hi)°  ↓ L: \(lo)°

        Shared via WeatherSwiftUI
        """
    }

    @ViewBuilder
    private func networkBanner(icon: String, message: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 13, weight: .bold))
            Text(message).font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.top, 58).padding(.bottom, 12)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.92).background(.ultraThinMaterial))
        .ignoresSafeArea(edges: .top)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
