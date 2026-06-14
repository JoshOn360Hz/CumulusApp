import SwiftUI
import WeatherKit
import CoreLocation
import WidgetKit


struct WeatherTabView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var cardManager = WeatherCardManager()
    @StateObject private var watchManager = WatchConnectivityManager.shared
    @EnvironmentObject private var appStateManager: AppStateManager
    @Binding var showSplash: Bool
    @State private var isUsingManualLocation = false
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "system"
    @State private var refreshTrigger = UUID()
    
    private var locationPermissionNotGranted: Bool {
        locationManager.authorizationStatus == CLAuthorizationStatus.denied ||
        locationManager.authorizationStatus == CLAuthorizationStatus.restricted
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                let isPad = UIDevice.current.userInterfaceIdiom == .pad
                
                ZStack {
                    weatherViewModel.backgroundGradient()
                        .edgesIgnoringSafeArea(.all)
                        .animation(.easeInOut(duration: 1.5), value: weatherViewModel.weather)
                        .transition(.opacity)
                    
                    Group {
                        if isPad && isLandscape, let weather = weatherViewModel.weather {
                            // iPad landscape: sticky left panel, scrollable right panel
                            HStack(alignment: .top, spacing: 0) {

                                // Left panel — weather card + recent searches, centered vertically
                                VStack(spacing: 16) {
                                    Spacer(minLength: 0)
                                    WeatherCardView(
                                        weather: weather,
                                        cityName: weatherViewModel.cityName,
                                        highTemp: weatherViewModel.forecastDays.first?.highTemperature,
                                        lowTemp: weatherViewModel.forecastDays.first?.lowTemperature
                                    )
                                    if !weatherViewModel.recentCities.filter({ !$0.isEmpty }).isEmpty {
                                        recentSearchesView
                                    }
                                    Spacer(minLength: 0)
                                }
                                .frame(width: min(geometry.size.width * 0.36, 360))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)

                                // Subtle divider
                                Rectangle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 1)
                                    .padding(.vertical, 24)

                                // Right panel — scrollable cards in 2-column grid for small cards
                                ScrollView {
                                    VStack(spacing: 12) {
                                        ForEach(cardManager.getCardSections()) { section in
                                            renderCardSection(section, weather: weather)
                                        }
                                        AppleWeatherAttributionView(
                                            condition: weather.currentWeather.condition.description
                                        )
                                        .padding(.top, 4)
                                        Spacer().frame(height: 16)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)
                                }
                                .scrollIndicators(.hidden)
                            }
                        } else {
                            ScrollView {
                                VStack(spacing: 10) {
                                    recentSearchesView
                                    Spacer().frame(height: 20)

                                    if let weather = weatherViewModel.weather {
                                        WeatherCardView(
                                            weather: weather,
                                            cityName: weatherViewModel.cityName,
                                            highTemp: weatherViewModel.forecastDays.first?.highTemperature,
                                            lowTemp: weatherViewModel.forecastDays.first?.lowTemperature
                                        )
                                        .padding(.horizontal)

                                        ForEach(cardManager.getCardSections()) { section in
                                            renderCardSection(section, weather: weather)
                                                .padding(.top, 16)
                                                .padding(.horizontal)
                                        }
                                    } else {
                                        if locationPermissionNotGranted {
                                            VStack(spacing: 16) {
                                                Image(systemName: "location.slash")
                                                    .font(.system(size: 40, weight: .bold))
                                                    .foregroundColor(.white.opacity(0.7))
                                                    .padding(.top, 250)
                                                Text("You have not granted location services permission, please search for a city.")
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal)
                                            }
                                            .padding()
                                        } else {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .padding()
                                        }
                                    }

                                    Spacer().frame(height: 20)
                                    AppleWeatherAttributionView(
                                        condition: weatherViewModel.weather?.currentWeather.condition.description ?? ""
                                    )
                                    Spacer().frame(height: 10)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .scrollIndicators(.hidden)
                            .refreshable {
                                await weatherViewModel.refresh()
                            }
                        }
                    }
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .onAppear {
            if let loc = locationManager.location {
                Task {
                    await weatherViewModel.fetchWeather(for: loc)
                }
            }
        }
        .onChange(of: locationManager.location) { oldValue, newValue in
            if !isUsingManualLocation, let loc = newValue {
                Task {
                    await weatherViewModel.fetchWeather(for: loc)
                }
            }
        }
        .onChange(of: weatherViewModel.weather) { oldValue, newValue in
            guard let weather = newValue else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let firstDay = weather.dailyForecast.first
                var sunriseStr: String? = nil
                var sunsetStr: String? = nil
                
                if let sunrise = firstDay?.sun.sunrise, let sunset = firstDay?.sun.sunset {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    if let timezone = weatherViewModel.locationTimeZone {
                        formatter.timeZone = timezone
                    }
                    sunriseStr = formatter.string(from: sunrise)
                    sunsetStr = formatter.string(from: sunset)
                }
                
                let precipitation = firstDay?.precipitationAmountByType.precipitation.value
                
                let sharedWeather = SharedWeather(
                    temperature: weather.currentWeather.temperature.converted(to: UnitTemperature.celsius).value,
                    condition: weather.currentWeather.condition.description,
                    symbolName: weather.currentWeather.symbolName,
                    isDaytime: weather.currentWeather.isDaylight,
                    location: weatherViewModel.cityName,
                    windSpeed: weather.currentWeather.wind.speed.value,
                    humidity: weather.currentWeather.humidity,
                    windDirection: weather.currentWeather.wind.direction.value,
                    feelsLike: weather.currentWeather.apparentTemperature.converted(to: UnitTemperature.celsius).value,
                    visibility: weather.currentWeather.visibility.value,
                    precipitation: precipitation,
                    pressure: weather.currentWeather.pressure.value,
                    uvIndex: weather.currentWeather.uvIndex.value,
                    sunrise: sunriseStr,
                    sunset: sunsetStr
                )
                
                saveWeatherToSharedDefaults(weather: sharedWeather)
                watchManager.sendWeatherToWatch(sharedWeather)
                WidgetCenter.shared.reloadTimelines(ofKind: "WeatherWidget")
            }
        }
        .onChange(of: appStateManager.selectedLocation) { oldValue, newValue in
            if let location = newValue {
                isUsingManualLocation = true
                Task {
                    await weatherViewModel.fetchWeather(for: location)
                }
                appStateManager.selectedLocation = nil
            }
        }
        .onChange(of: temperatureUnit) { oldValue, newValue in
            refreshTrigger = UUID()
            WatchConnectivityManager.shared.sendUnitsToWatch()
        }
        .id(refreshTrigger)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    
    @ViewBuilder
    func renderCardSection(_ section: CardSection, weather: Weather) -> some View {
        switch section {
        case .smallPair(let card1, let card2):
            HStack(spacing: 20) {
                renderSmallCard(card1, weather: weather)
                renderSmallCard(card2, weather: weather)
            }
        case .singleSmall(let card):
            HStack(spacing: 20) {
                renderSmallCard(card, weather: weather)
                    .frame(maxWidth: .infinity)
                Color.clear
                    .frame(maxWidth: .infinity)
            }
        case .large(let card):
            renderLargeCard(card, weather: weather)
        }
    }

    @ViewBuilder
    func renderSmallCard(_ cardType: WeatherCardType, weather: Weather) -> some View {
        switch cardType {
        case .windDirection:
            WindDirectionCardView(
                directionDegrees: weather.currentWeather.wind.direction.value,
                speed: weather.currentWeather.wind.speed
            )
        case .feelsLike:
            FeelsLikeCardView(feelsLike: weather.currentWeather.apparentTemperature)
        case .visibility:
            VisibilityCardView(visibility: weather.currentWeather.visibility)
        case .precipitation:
            if let firstDay = weather.dailyForecast.first {
                let dailyPrecip = firstDay.precipitationAmountByType.precipitation
                PrecipitationCardView(dailyPrecipitation: dailyPrecip)
            }
        case .pressure:
            PressureMiniCardView(pressure: weather.currentWeather.pressure)
        case .uvIndex:
            UVIndexCardView(uvIndex: weather.currentWeather.uvIndex.value)
        case .humidity:
            HumidityCardView(humidity: weather.currentWeather.humidity)
        case .dewPoint:
            DewPointCardView(dewPoint: weather.currentWeather.dewPoint)
        case .cloudCover:
            CloudCoverCardView(cloudCover: weather.currentWeather.cloudCover)
        case .windGust:
            if let gust = weather.currentWeather.wind.gust {
                WindGustCardView(gust: gust)
            } else {
                WindGustCardView(gust: weather.currentWeather.wind.speed)
            }
        case .moonPhase:
            MoonPhaseCardView(moonPhase: weatherViewModel.moonPhase)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func renderLargeCard(_ cardType: WeatherCardType, weather: Weather) -> some View {
        switch cardType {
        case .hourlyForecast:
            if !weatherViewModel.hourlyForecast.isEmpty {
                HourlyForecastCardView(
                    hourlyForecast: weatherViewModel.hourlyForecast,
                    locationTimeZone: weatherViewModel.locationTimeZone
                )
            }
        case .forecast:
            if !weatherViewModel.forecastDays.isEmpty {
                ForecastCardView(forecastDays: weatherViewModel.forecastDays)
            }
        case .sunTimes:
            if let firstDay = weather.dailyForecast.first,
               let sunrise = firstDay.sun.sunrise,
               let sunset = firstDay.sun.sunset {
                SunTimesCardsView(
                    sunrise: sunrise,
                    sunset: sunset,
                    timeZone: weatherViewModel.locationTimeZone
                )
            }
        default:
            EmptyView()
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

