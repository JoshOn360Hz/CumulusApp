import SwiftUI
import WeatherKit
import CoreLocation

// MARK: - Apple Weather Attribution View
struct AppleWeatherAttributionView: View {
    var condition: String
    var textColor: Color {
        // Use black text on cloudy conditions; white otherwise.
        condition.lowercased().contains("cloud") ? .black : .white
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Weather data provided by Weather")
                .font(.caption)
                .foregroundColor(textColor.opacity(0.8))
            Link("Click to view legal info", destination: URL(string: "https://weather-data.apple.com/legal-attribution.html")!)
                .font(.caption)
                .foregroundColor(textColor)
               
        }
    }
}

// MARK: - Main Weather View for macOS
struct WeatherView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @State private var showSearch = false
    @State private var isUsingManualLocation = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            weatherViewModel.backgroundGradient()
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: 1.5), value: weatherViewModel.weather)
                .transition(.opacity)
            
            // Main scrollable content with a three-column layout
            ScrollView {
                VStack(spacing: 10) {
                    recentSearchesView
                    Spacer().frame(height: 20)
                        .padding(.top,30)

                    if let weather = weatherViewModel.weather {
                        HStack(alignment: .top, spacing: -200) {
                            // LEFT COLUMN
                            VStack(spacing: 20) {
                                if let firstDay = weather.dailyForecast.first,
                                   let sunrise = firstDay.sun.sunrise,
                                   let sunset = firstDay.sun.sunset {
                                    SunTimesCardsView(
                                        sunrise: sunrise,
                                        sunset: sunset,
                                        timeZone: weatherViewModel.locationTimeZone
                                    )
                                } else {
                                    placeholderRow("Sunrise", "Sunset")
                                }
                                if !weatherViewModel.forecastDays.isEmpty {
                                    ForecastCardView(forecastDays: weatherViewModel.forecastDays)
                                        .frame(width: 600, height: 160)
                                        .padding(.top,10)

                                }
                                HStack(spacing: 20) {
                                    WindDirectionCardView(
                                        directionDegrees: weather.currentWeather.wind.direction.value,
                                        speed: weather.currentWeather.wind.speed
                                    )
                                    FeelsLikeCardView(
                                        feelsLike: weather.currentWeather.apparentTemperature
                                    )
                                }
                                
                             

                            }
                            

                            // CENTER COLUMN (Main Weather Card)
                            WeatherCardView(weather: weather, cityName: weatherViewModel.cityName)
                                .frame(width: 600, height: 450)
                       

                            // RIGHT COLUMN
                            VStack(spacing: 20) {
                                HStack(spacing: 20) {
                                    VisibilityCardView(visibility: weather.currentWeather.visibility)
                                    if let firstDay = weather.dailyForecast.first {
                                        let dailyPrecip = firstDay.precipitationAmountByType.precipitation
                                        PrecipitationCardView(dailyPrecipitation: dailyPrecip)
                                    } else {
                                        placeholderRow("Visibility", "Precip")
                                    }
                                }
                                if !weatherViewModel.hourlyForecast.isEmpty {
                                    HourlyForecastCardView(
                                        hourlyForecast: weatherViewModel.hourlyForecast,
                                        locationTimeZone: weatherViewModel.locationTimeZone
                                    )
                                    .frame(width: 600, height: 180)
                                }
                                
                                HStack(spacing: 20) {
                                    PressureMiniCardView(pressure: weather.currentWeather.pressure)
                                    UVIndexCardView(uvIndex: weather.currentWeather.uvIndex.value)
                                }
                                
                                
                            }
                        }
                        .frame(width: 1100) // <== Fixed width to prevent stretching
                        .frame(maxWidth: .infinity) // <== Ensures it stays centered
                        .padding(.top, 0)
                        .transition(.opacity)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding()
                    }

                    Spacer().frame(height: 20)

                    // Apple Attribution
                    AppleWeatherAttributionView(
                        condition: weatherViewModel.weather?.currentWeather.condition.description ?? ""
                    )
                    Spacer().frame(height: 90)
                }
                .frame(maxWidth: .infinity) // <== Allows background to stretch
                .padding(.bottom, 25)
            }
            .scrollIndicators(.hidden)
            
            // Pinned bottom dock
            dockView
                .edgesIgnoringSafeArea(.bottom)
            
            // Search overlay
            SearchPlaceView(isPresented: $showSearch) { location in
                isUsingManualLocation = true
                Task {
                    await weatherViewModel.fetchWeather(for: location)
                }
            }
        }
        // Set a minimum frame size for a resizable window on macOS
        .frame(minWidth: 1200, minHeight: 800)
        .onAppear {
            if let loc = locationManager.location {
                Task {
                    await weatherViewModel.fetchWeather(for: loc)
                }
            }
        }
        .onChange(of: locationManager.location) { newLocation in
            if !isUsingManualLocation, let loc = newLocation {
                Task {
                    await weatherViewModel.fetchWeather(for: loc)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var recentSearchesView: some View {
        HStack(spacing: 10) {
            ForEach(weatherViewModel.recentCities.filter { !$0.isEmpty }, id: \.self) { city in
                Button {
                    Task {
                        do {
                            let location = try await geocodeCity(city)
                            await weatherViewModel.fetchWeather(for: location)
                            isUsingManualLocation = true
                        } catch {
                            print("Error geocoding \(city): \(error)")
                        }
                    }
                } label: {
                    Text(city.components(separatedBy: ",").first ?? city)
                }
                .buttonStyle(GlassButtonStyle())
            }
        }
        .padding(.top, 20)
    }
    
    private var dockView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 35, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 35, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -2)
            
            HStack(spacing: 20) {
                Button {
                    withAnimation(.spring()) {
                        showSearch = true
                    }
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .buttonStyle(GlassButtonStyle())
                
                Button {
                    isUsingManualLocation = false
                    if let loc = locationManager.location {
                        Task {
                            await weatherViewModel.fetchWeather(for: loc)
                        }
                    }
                } label: {
                    Label("Current Location", systemImage: "location.fill")
                }
                .buttonStyle(GlassButtonStyle())
            }
            .padding(40)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .offset(y: -10)
        
    }
    
    // MARK: - Helper to geocode a city string into a CLLocation.
    private func geocodeCity(_ city: String) async throws -> CLLocation {
        let placemarks = try await CLGeocoder().geocodeAddressString(city)
        guard let first = placemarks.first, let location = first.location else {
            throw NSError(domain: "NoLocation", code: 404, userInfo: nil)
        }
        return location
    }
    
    // MARK: - Placeholder Helpers
    private func placeholderRow(_ left: String, _ right: String) -> some View {
        HStack(spacing: 20) {
            placeholderCard(title: left)
            placeholderCard(title: right)
        }
    }
    
    private func placeholderCard(title: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text("--")
                .font(.title2)
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: 220, height: 140)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}
