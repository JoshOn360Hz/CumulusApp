import SwiftUI
import CoreLocation


struct SearchTabView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject private var appStateManager: AppStateManager
    @State private var searchText: String = ""
    @State private var searchResults: [CLPlacemark] = []
    @State private var isSearching = false
    @AppStorage("accentColorName") private var accentColorName: String = "blue"

    var accentColor: Color {
        switch accentColorName {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        case "mint": return .mint
        default: return .blue
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if searchResults.isEmpty && !isSearching && searchText.isEmpty {
                    // Recent searches and help text
                    VStack(spacing: 30) {
                        // Current Location Button
                        Button {
                            useCurrentLocation()
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(accentColor)
                                Text("Use Current Location")
                                    .foregroundColor(accentColor)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(accentColor.opacity(0.7))
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1)) 
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(accentColor.opacity(0.8), lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        if !weatherViewModel.recentCities.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Searches")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(weatherViewModel.recentCities.filter { !$0.isEmpty }, id: \.self) { city in
                                    Button {
                                        selectRecentCity(city)
                                    } label: {
                                        HStack {
                                            Image(systemName: "clock.arrow.circlepath")
                                                .foregroundColor(accentColor)
                                            Text(city.components(separatedBy: ",").first ?? city)
                                                .foregroundColor(accentColor)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                        }
                                        .padding()
                                        .background(accentColor.opacity(0.1))
                                        
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    // Search results
                    VStack {
                        if isSearching {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Searching...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding()
                        }
                        
                        List(searchResults, id: \.self) { placemark in
                            Button {
                                selectLocation(placemark)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(placemark.name ?? "Unknown")
                                            .font(.headline)
                                            .foregroundColor(accentColor)
                                        
                                        if let locality = placemark.locality,
                                           let country = placemark.country {
                                            Text("\(locality), \(country)")
                                                .font(.subheadline)
                                                .foregroundColor(accentColor.opacity(0.5))
                                        } else if let country = placemark.country {
                                            Text(country)
                                                .font(.subheadline)
                                                .foregroundColor(accentColor.opacity(0.5))
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundColor(accentColor)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(PlainListStyle())
                        
                        if !isSearching && searchResults.isEmpty && !searchText.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "location.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("No locations found")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Try searching for a different city or location")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search for a city or location")
            .onSubmit(of: .search) {
                performSearch()
            }
            .onChange(of: searchText) { oldValue, newValue in
                if newValue.isEmpty {
                    searchResults = []
                    isSearching = false
                } else if newValue.count >= 2 {
                    // Start searching after 2 characters
                    isSearching = true
                    // Debounce search with shorter delay for better responsiveness
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if newValue == searchText {
                            performSearch()
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(searchText) { placemarks, error in
            DispatchQueue.main.async {
                isSearching = false
                if let placemarks = placemarks {
                    // Limit to 5 results for better UX
                    searchResults = Array(placemarks.prefix(5))
                } else {
                    searchResults = []
                }
            }
        }
    }
    
    private func selectLocation(_ placemark: CLPlacemark) {
        guard let location = placemark.location else { return }
        
        
        // Save to recent searches
        let cityName = placemark.locality ?? placemark.name ?? "Unknown Location"
        weatherViewModel.addRecentCity(cityName)
        
        // Use shared state manager to update location and switch to weather tab
        appStateManager.selectLocationAndSwitchToWeather(location: location, cityName: cityName)
    }
    
    private func selectRecentCity(_ city: String) {
        Task {
            do {
                let location = try await geocodeCity(city)
                
            
                // Use shared state manager to update location and switch to weather tab
                appStateManager.selectLocationAndSwitchToWeather(location: location, cityName: city)
            } catch {
                print("Error geocoding \(city): \(error)")
            }
        }
    }
    
    private func useCurrentLocation() {
        guard let currentLocation = locationManager.location else {

            print("Location not available, ensure location permissions are granted")
            return
        }
        
        // Use shared state manager to update location and switch to weather tab
        appStateManager.selectLocationAndSwitchToWeather(location: currentLocation, cityName: "Current Location")
    }
    
    private func geocodeCity(_ city: String) async throws -> CLLocation {
        let placemarks = try await CLGeocoder().geocodeAddressString(city)
        guard let first = placemarks.first, let location = first.location else {
            throw NSError(domain: "NoLocation", code: 404, userInfo: nil)
        }
        return location
    }
}
