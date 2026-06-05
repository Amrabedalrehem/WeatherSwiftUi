//
//  ManageCitiesView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 02/06/2026.
//


import SwiftUI

struct ManageCitiesView: View {

    @EnvironmentObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedPreviewWeather: WeatherResponse? = nil
    @State private var navigateToSearch: Bool = false
    @State private var showRemoveAlert: Bool = false
    @State private var locationToRemove: SavedLocation? = nil

      private var currentCondition: String {
        viewModel.weatherResponse?.current.condition.text ?? ""
    }
    private func checkIfIsDay() -> Bool {
        (viewModel.weatherResponse?.current.is_day ?? 1) == 1
    }
    private var fontColor: Color { checkIfIsDay() ? .black : .white }



     var body: some View {
        ZStack {
             if viewModel.weatherResponse != nil {
                VideoBackgroundView(condition: currentCondition, isDay: checkIfIsDay())
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.12, blue: 0.28),
                        Color(red: 0.10, green: 0.22, blue: 0.42)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }

            Color.black.opacity(checkIfIsDay() ? 0.15 : 0.35)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                  HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Home")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(fontColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }

                    Spacer()

                    Text("Manage Cities")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(fontColor)

                    Spacer()

                    Color.clear.frame(width: 80, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 12)

                   searchBarButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                   ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        if !viewModel.savedLocations.isEmpty {
                            savedCitiesSection
                                .padding(.horizontal, 20)
                                .padding(.bottom, 40)
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .navigationDestination(item: $selectedPreviewWeather) { weather in
            WeatherPreviewView(weather: weather)
        }
        .navigationDestination(isPresented: $navigateToSearch) {
            SearchView().environmentObject(viewModel)
        }
        .onAppear {
            viewModel.fetchSavedLocations()
            Task { await viewModel.fetchAllSavedWeather() }
        }
        .alert("Remove Favorite?", isPresented: $showRemoveAlert) {
            Button("Remove", role: .destructive) {
                if let location = locationToRemove {
                    withAnimation(.spring()) {
                        viewModel.toggleLocationFromSearch(location: location)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let location = locationToRemove {
                Text("Are you sure you want to remove \(location.name) from your favorites?")
            }
        }
    }
    private var searchBarButton: some View {
        Button {
            navigateToSearch = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 16, weight: .semibold))

                Text("Search city...")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 16))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

      private var savedCitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 11))
                Text("SAVED CITIES")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(fontColor.opacity(0.75))
            }

            VStack(spacing: 12) {
                ForEach(viewModel.savedLocations, id: \.name) { location in
                    savedCityCard(location: location)
                }
            }
        }
    }

    private func savedCityCard(location: SavedLocation) -> some View {
          let liveWeather = viewModel.savedWeatherResponses.first {
            $0.location.name.lowercased() == location.name.lowercased()
        }

     
        return GlassCardView {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Text(location.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(fontColor)
                    }

                    if let w = liveWeather {
                        Text(w.current.condition.text)
                            .font(.system(size: 13))
                            .foregroundColor(fontColor.opacity(0.65))
                        Text("H:\(Int(w.forecast.forecastday.first?.day.maxtemp_c ?? 0))°  L:\(Int(w.forecast.forecastday.first?.day.mintemp_c ?? 0))°")
                            .font(.system(size: 12))
                            .foregroundColor(fontColor.opacity(0.5))
                    } else {
                        Text(location.country)
                            .font(.system(size: 13))
                            .foregroundColor(fontColor.opacity(0.55))
                    }
                }

                Spacer()

                  VStack(alignment: .trailing, spacing: 8) {
                    if let w = liveWeather {
                        Text("\(Int(w.current.temp_c))°")
                            .font(.system(size: 44, weight: .thin))
                            .foregroundColor(fontColor)
                    }

                    Button {
                        locationToRemove = location
                        showRemoveAlert = true
                    } label: {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 18))
                    }
                }
            }
        }
        .onTapGesture {
            Task {
                if let w = liveWeather {
                    selectedPreviewWeather = w
                } else {
                    if let result = try? await viewModel.searchCity(query: location.name) {
                        selectedPreviewWeather = result
                    }
                }
            }
        }
    }



    private func formatLocalTime(_ localtime: String) -> String {
          let parts = localtime.split(separator: " ")
        guard parts.count == 2 else { return "" }
        let timePart = String(parts[1])
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let date = formatter.date(from: timePart) else { return timePart }
        let out = DateFormatter()
        out.dateFormat = "h:mm a"
        return out.string(from: date)
    }
}
 
