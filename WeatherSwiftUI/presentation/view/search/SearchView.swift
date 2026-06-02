import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var searchedWeather: WeatherResponse?
    @State private var searchError: String?
    @State private var navigateToWeather: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    // MARK: - Search Bar
                    searchBar
                    
                    // MARK: - Search Result
                    if isSearching {
                        ProgressView()
                            .tint(.white)
                            .padding(.top, 20)
                        
                    } else if let weather = searchedWeather {
                        searchResultView(weather: weather)
                        
                    } else if let error = searchError {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.top, 20)
                    }
                    
                    // MARK: - Saved Locations
                    if !viewModel.savedLocations.isEmpty {
                        savedLocationsSection
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            viewModel.fetchSavedLocations()
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search city...", text: $searchText)
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .onSubmit {
                    searchCity()
                }
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    searchedWeather = nil
                    searchError = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Search Result
    private func searchResultView(weather: WeatherResponse) -> some View {
        GlassCardView {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(weather.location.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(weather.location.country)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(weather.current.condition.text)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(Int(weather.current.temp_c))°")
                        .font(.system(size: 36, weight: .thin))
                        .foregroundColor(.white)
                    
                    // Save Toggle Button
                    Button {
                        let location = SavedLocation(
                            name: weather.location.name,
                            lat: weather.location.lat,
                            lon: weather.location.lon,
                            country: weather.location.country
                        )
                        try? viewModel.toggleLocationUseCase(location)
                        viewModel.fetchSavedLocations()
                    } label: {
                        Image(systemName: isSaved(weather.location.name) ?
                              "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .onTapGesture {
            viewModel.weatherResponse = searchedWeather
            dismiss()
        }
    }
    
    // MARK: - Saved Locations
    private var savedLocationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SAVED LOCATIONS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            
            ForEach(viewModel.savedLocations, id: \.name) { location in
                SavedLocationRowView(location: location)
                    .onTapGesture {
                        Task {
                            await viewModel.fetchWeather(
                                lat: location.lat,
                                lon: location.lon
                            )
                            dismiss()
                        }
                    }
            }
        }
    }
    
    // MARK: - Search Function
    private func searchCity() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        searchError = nil
        searchedWeather = nil
        
        Task {
            do {
                let result = try await viewModel.searchCityUseCase(query: searchText)
                await MainActor.run {
                    searchedWeather = result
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    searchError = "City not found!"
                    isSearching = false
                }
            }
        }
    }
    
    // MARK: - Is Saved
    private func isSaved(_ name: String) -> Bool {
        viewModel.savedLocations.contains { $0.name == name }
    }
}