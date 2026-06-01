import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: WeatherViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    private func checkIfIsDay() -> Bool {
        guard let weather = viewModel.weatherResponse else { return true }
        let iconURLString = weather.current.condition.icon.lowercased()
        return !iconURLString.contains("night")
    }
    
    private var dynamicFontColor: Color {
        if viewModel.weatherResponse != nil {
            return checkIfIsDay() ? .black : .white
        }
        return .white
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if let weather = viewModel.weatherResponse {
                    VideoBackgroundView(
                        condition: weather.current.condition.text,
                        isDay: checkIfIsDay()
                    )
                    .ignoresSafeArea()
                } else {
                    Color(red: 0.1, green: 0.25, blue: 0.45)
                        .ignoresSafeArea()
                }
                
                VStack(spacing: 0) {
                    if let weather = viewModel.weatherResponse {
                   ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 20) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(dynamicFontColor)
                                        .padding(.top, 10)
                                }
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Text(weather.location.name)
                                            .font(.system(size: 34, weight: .medium))
                                            .foregroundColor(dynamicFontColor)
                                        
                                        Button(action: {
                                            viewModel.toggleCurrentLocation()
                                        }) {
                                            Image(systemName: viewModel.isCurrentLocationSaved ? "star.fill" : "star")
                                                .foregroundColor(viewModel.isCurrentLocationSaved ? .yellow : dynamicFontColor)
                                                .font(.title2)
                                        }
                                    }
                                    
                                    Text("\(Int(weather.current.temp_c))°")
                                        .font(.system(size: 80, weight: .thin))
                                        .foregroundColor(dynamicFontColor)
                                    
                                    Text(weather.current.condition.text)
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(dynamicFontColor.opacity(0.8))
                                    
                                    Text("H:\(Int(weather.forecast.forecastday.first?.day.maxtemp_c ?? 0))°  L:\(Int(weather.forecast.forecastday.first?.day.mintemp_c ?? 0))°")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(dynamicFontColor.opacity(0.8))
                                }
                                .padding(.top, viewModel.isLoading ? 10 : 40)
                                
                                if let firstDay = weather.forecast.forecastday.first {
                                    GlassCardView {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("HOURLY FORECAST")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(dynamicFontColor.opacity(0.6))
                                            
                                            Divider().background(dynamicFontColor.opacity(0.3))
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 20) {
                                                    ForEach(firstDay.hour.prefix(6), id: \.time) { hour in
                                                        VStack(spacing: 8) {
                                                            Text(formatToHour(hour.time))
                                                                .font(.system(size: 14, weight: .medium))
                                                                .foregroundColor(dynamicFontColor)
                                                            
                                                            AsyncImage(url: URL(string: "https:\(hour.condition.icon)")) { image in
                                                                image.resizable().scaledToFit()
                                                            } placeholder: {
                                                                ProgressView()
                                                            }
                                                            .frame(width: 30, height: 30)
                                                            
                                                            Text("\(Int(hour.temp_c))°")
                                                                .font(.system(size: 16, weight: .semibold))
                                                                .foregroundColor(dynamicFontColor)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                GlassCardView {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Label("3-DAY FORECAST", systemImage: "calendar")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(dynamicFontColor.opacity(0.6))
                                        
                                        Divider().background(dynamicFontColor.opacity(0.3))
                                        
                                        ForEach(weather.forecast.forecastday, id: \.date) { day in
                                            NavigationLink(destination: HourlyView(forecastDay: day, fontColor: dynamicFontColor)) {
                                                ForecastRowView(forecastDay: day, fontColor: dynamicFontColor)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            
                                            if day.date != weather.forecast.forecastday.last?.date {
                                                Divider().background(dynamicFontColor.opacity(0.2))
                                            }
                                        }
                                    }
                                }
                                
                                WeatherDetailGridView(current: weather.current, fontColor: dynamicFontColor)
                                
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        
                    } else if viewModel.isLoading {
                        ProgressView("Loading Weather...")
                            .tint(.white)
                            .foregroundColor(.white)
                            .font(.headline)
                        
                    } else if let error = viewModel.errorMessage {
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
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await viewModel.fetchDefaultWeather()
                }
            }
            .onChange(of: locationManager.currentLocation) { _, newLocation in
                guard let location = newLocation else { return }
                if viewModel.weatherResponse == nil {
                    Task {
                        await viewModel.fetchWeather(
                            lat: location.coordinate.latitude,
                            lon: location.coordinate.longitude
                        )
                    }
                }
            }
        }
    }
    
    private func formatToHour(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let date = formatter.date(from: timeString) else { return timeString }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h a"
        return outputFormatter.string(from: date)
    }
}
