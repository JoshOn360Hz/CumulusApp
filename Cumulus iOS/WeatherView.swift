import SwiftUI
import WeatherKit
import CoreLocation
import WidgetKit
struct AppleWeatherAttributionView: View {
    var condition: String
    var textColor: Color {
        condition.lowercased().contains("cloud") ? .black : .white
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Weather data provided by Weather")
                .font(.caption)
                .foregroundColor(textColor.opacity(0.8))
            Link(" Tap to view legal info ", destination: URL(string: "https://weather-data.apple.com/legal-attribution.html")!)
                .font(.caption)
                .foregroundColor(textColor)
        }
    }
}

struct WeatherView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @Binding var showSplash: Bool
    @State private var showSearch = false
    @State private var isUsingManualLocation = false
    @State private var showIconPicker = false

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let isPad = UIDevice.current.userInterfaceIdiom == .pad

            ZStack(alignment: .bottom) {
                weatherViewModel.backgroundGradient()
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut(duration: 1.5), value: weatherViewModel.weather)
                    .transition(.opacity)

                ScrollView {
                    VStack(spacing: 10) {
                        recentSearchesView
                        Spacer().frame(height: 20)

                        if let weather = weatherViewModel.weather {
                            if isPad && isLandscape {
                                // iPad Landscape Layout
                                HStack(alignment: .top, spacing: -200) {
                                    leftColumn(for: weather)
                                    WeatherCardView(weather: weather, cityName: weatherViewModel.cityName)
                                        .frame(width: 600, height: 450)
                                    rightColumn(for: weather)
                                }
                                .frame(width: 1100)
                                .frame(maxWidth: .infinity)
                            } else {
                                // iPhone and iPad Portrait Layout
                                WeatherCardView(weather: weather, cityName: weatherViewModel.cityName)
                                    .padding(.horizontal)

                                if weather.dailyForecast.first != nil {
                                    HStack(spacing: 20) {
                                        WindDirectionCardView(
                                            directionDegrees: weather.currentWeather.wind.direction.value,
                                            speed: weather.currentWeather.wind.speed
                                        )
                                        FeelsLikeCardView(feelsLike: weather.currentWeather.apparentTemperature)
                                    }
                                    .padding(.top, 20)
                                    .padding(.horizontal)
                                }

                                if !weatherViewModel.hourlyForecast.isEmpty {
                                    HourlyForecastCardView(
                                        hourlyForecast: weatherViewModel.hourlyForecast,
                                        locationTimeZone: weatherViewModel.locationTimeZone
                                    )
                                    .padding(.top, 20)
                                    .padding(.horizontal)
                                }

                                HStack(spacing: 20) {
                                    VisibilityCardView(visibility: weather.currentWeather.visibility)
                                    if let firstDay = weather.dailyForecast.first {
                                        let dailyPrecip = firstDay.precipitationAmountByType.precipitation
                                        PrecipitationCardView(dailyPrecipitation: dailyPrecip)
                                    }
                                }
                                .padding(.top, 20)
                                .padding(.horizontal)

                                if !weatherViewModel.forecastDays.isEmpty {
                                    ForecastCardView(forecastDays: weatherViewModel.forecastDays)
                                        .padding(.top, 20)
                                        .padding(.horizontal)
                                }

                                if let firstDay = weather.dailyForecast.first,
                                   let sunrise = firstDay.sun.sunrise,
                                   let sunset = firstDay.sun.sunset {
                                    SunTimesCardsView(
                                        sunrise: sunrise,
                                        sunset: sunset,
                                        timeZone: weatherViewModel.locationTimeZone
                                    )
                                    .padding(.top, 20)
                                    .padding(.horizontal)
                                }

                                HStack(spacing: 20) {
                                    PressureMiniCardView(pressure: weather.currentWeather.pressure)
                                    UVIndexCardView(uvIndex: weather.currentWeather.uvIndex.value)
                                }
                                .padding(.top, 20)
                                .padding(.horizontal)
                            }

                            Button("Settings") {
                                showIconPicker = true
                            }
                            .buttonStyle(GlassButtonStyle())
                            .padding(.top, 20)
                            .padding(.horizontal)
                            .sheet(isPresented: $showIconPicker) {
                                IconPickerSheet(showSheet: $showIconPicker, showSplash: $showSplash)
                            }

                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding()
                        }

                        Spacer().frame(height: 20)

                        AppleWeatherAttributionView(
                            condition: weatherViewModel.weather?.currentWeather.condition.description ?? ""
                        )

                        Spacer().frame(height: 90)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 25)
                }
                .scrollIndicators(.hidden)

                dockView
                    .edgesIgnoringSafeArea(.bottom)

                SearchPlaceView(isPresented: $showSearch) { location in
                    isUsingManualLocation = true
                    Task {
                        await weatherViewModel.fetchWeather(for: location)
                    }
                }
            }
            .onAppear {
                if let loc = locationManager.location {
                    Task {
                        await weatherViewModel.fetchWeather(for: loc)
                    }
                }
            }
            .onChange(of: locationManager.location) { _ in
                if !isUsingManualLocation, let loc = locationManager.location {
                    Task {
                        await weatherViewModel.fetchWeather(for: loc)
                    }
                }
            }
            .onChange(of: weatherViewModel.weather) { weather in
                guard let weather = weather else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let sharedWeather = SharedWeather(
                        temperature: weather.currentWeather.temperature.converted(to: UnitTemperature.celsius).value,
                        condition: weather.currentWeather.condition.description,
                        symbolName: weather.currentWeather.symbolName,
                        isDaytime: weather.currentWeather.isDaylight,
                        location: weatherViewModel.cityName,
                        windSpeed: weather.currentWeather.wind.speed.value,
                        humidity: weather.currentWeather.humidity
                    )
                    saveWeatherToSharedDefaults(weather: sharedWeather)
                    WidgetCenter.shared.reloadTimelines(ofKind: "WeatherWidget")
                }
            }
        }
    }

    // MARK: - Left Column
    func leftColumn(for weather: Weather) -> some View {
        VStack(spacing: 20) {
            if let firstDay = weather.dailyForecast.first,
               let sunrise = firstDay.sun.sunrise,
               let sunset = firstDay.sun.sunset {
                SunTimesCardsView(sunrise: sunrise, sunset: sunset, timeZone: weatherViewModel.locationTimeZone)
            }
            if !weatherViewModel.forecastDays.isEmpty {
                ForecastCardView(forecastDays: weatherViewModel.forecastDays)
                    .frame(width: 600, height: 160)
                    .padding(.top, 10)
            }
            HStack(spacing: 20) {
                WindDirectionCardView(
                    directionDegrees: weather.currentWeather.wind.direction.value,
                    speed: weather.currentWeather.wind.speed
                )
                FeelsLikeCardView(feelsLike: weather.currentWeather.apparentTemperature)
            }
        }
    }

    // MARK: - Right Column
    func rightColumn(for weather: Weather) -> some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                VisibilityCardView(visibility: weather.currentWeather.visibility)
                if let firstDay = weather.dailyForecast.first {
                    let dailyPrecip = firstDay.precipitationAmountByType.precipitation
                    PrecipitationCardView(dailyPrecipitation: dailyPrecip)
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
                .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.white.opacity(0.3), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -2)

            HStack(spacing: 20) {
                Button {
                    withAnimation(.spring()) { showSearch = true }
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .buttonStyle(GlassButtonStyle())

                Button {
                    isUsingManualLocation = false
                    if let loc = locationManager.location {
                        Task { await weatherViewModel.fetchWeather(for: loc) }
                    }
                } label: {
                    Label("Current Location", systemImage: "location.fill")
                }
                .buttonStyle(GlassButtonStyle())
            }
            .padding(30)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .offset(y: 20)
        .ignoresSafeArea(edges: .bottom)
    }

    private func geocodeCity(_ city: String) async throws -> CLLocation {
        let placemarks = try await CLGeocoder().geocodeAddressString(city)
        guard let first = placemarks.first, let location = first.location else {
            throw NSError(domain: "NoLocation", code: 404, userInfo: nil)
        }
        return location
    }

    func saveWeatherToSharedDefaults(weather: SharedWeather) {
        if let data = try? JSONEncoder().encode(weather) {
            let defaults = UserDefaults(suiteName: "group.com.josh.cumulus")
            defaults?.set(data, forKey: "currentWeather")
        } else {
            print("Failed to encode weather.")
        }
    }
}
