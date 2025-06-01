import SwiftUI
import WeatherKit
import CoreLocation

// MARK: - Models

/// Represents one day of forecast data (daily forecast).
struct ForecastDay: Identifiable {
    let id = UUID()
    let day: String
    let iconName: String
    let highTemperature: Double
}

/// Represents one hour of forecast data (hourly forecast).
struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: Date
    let symbolName: String
    let temperature: Double
}


// MARK: - Weather Icon Helper
/// A helper function to map WeatherKit’s symbolName to an SF Symbol you want to display.
func getWeatherIcon(for symbol: String) -> String {
    switch symbol {
        case "moon", "moon.stars":
            return "moon.stars"
    case "sun.max", "sun.max.fill":
        return "sun.max.fill"
    case "cloud.sun", "cloud.sun.fill":
        return "cloud.sun.fill"
    case "moon.fill":
        return "moon.fill"
    case "Drizzle", "cloud.drizzle":
        return "cloud.drizzle"
    case "cloud.moon", "cloud.moon.fill":
        return "cloud.moon.fill"
    case "cloud", "cloud.fill":
        return "cloud.fill"
    case "cloud.rain", "cloud.rain.fill":
        return "cloud.rain.fill"
    case "snow", "snowflake":
        return "snowflake"
    case "cloud.fog", "cloud.fog.fill":
        return "cloud.fog.fill"
    case "wind":
        return "wind"
    case "cloud.hail", "cloud.hail.fill":
        return "cloud.hail.fill"
    case "overcast", "overcast.fill":
            return "cloud.fill"
    case "hail", "hail.fill":
        return "cloud.hail.fill"
    case "sleet", "sleet.fill":
         return "cloud.sleet.fill"
    case "drizzle", "cloud.drizzle.fill":
        return "cloud.drizzle.fill"
    case "light rain", "light.rain.fill":
        return "cloud.rain.fill"
    case "heavy rain", "heavy.rain.fill","cloud.heavyrain.fill","cloud.heavyrain":
        return "cloud.rain.fill"
    case "rain", "rain.fill":
        return "cloud.rain.fill"
    default:
        return "cloud.fill"
    
    }
}

// MARK: - WeatherViewModel

@MainActor
class WeatherViewModel: ObservableObject {
    
    // Published properties
    @Published var airQualityIndex: Int? = nil
    @Published var weather: Weather?
    @Published var cityName: String = "Loading..."
    @Published var forecastDays: [ForecastDay] = []
    @Published var hourlyForecast: [HourlyForecast] = []
    @Published var recentCities: [String] = []
    private let sharedDefaults = UserDefaults(suiteName: "group.com.josh.cumulus")
    private let weatherService = WeatherService()
    
    // MARK: - Init
    
    init() {
        let savedCities = UserDefaults.standard.stringArray(forKey: "RecentSearches") ?? []
        if savedCities.isEmpty {
            recentCities = []
            UserDefaults.standard.set(recentCities, forKey: "RecentSearches")
        } else {
            recentCities = savedCities
        }
    }
    
    // MARK: - Main Fetch Weather
    // Fetches the main WeatherKit data for a given CLLocation (daily & current),
    // then calls `fetchHourlyForecast(for:)` for the next 12 hours.
    
    func fetchWeather(for location: CLLocation) async {
        do {
            // 1) Get the main Weather object (current + daily)
            let weather = try await weatherService.weather(for: location)
            self.weather = weather
            
            // 2) Reverse-geocode to get a city name
            await fetchCityName(for: location)
            
            // 3) Insert city name into recentCities if valid
            if !cityName.isEmpty && cityName != "Unknown" {
                insertCurrentCityAsFirst(cityName)
            }
            
            // 4) Update daily forecast array
            updateForecast(from: weather)
            
            // 5) Fetch hourly forecast for next 12 hours
            await fetchHourlyForecast(for: location)
            
            // 6) Save location for widget usage
            let coords = ["lat": location.coordinate.latitude, "lon": location.coordinate.longitude]
            sharedDefaults?.set(coords, forKey: "LastLocation")
            sharedDefaults?.synchronize()
            
        } catch {
            print("Error fetching weather: \(error)")
        }
    }
    
    // MARK: - Hourly Forecast (12 hours using the .hourly API)
    
    /// Fetches the next 12 hours of HourWeather using WeatherKit’s .hourly API,
    /// then maps them into your HourlyForecast model.
    func fetchHourlyForecast(for location: CLLocation) async {
        let startDate = Date()
        guard let endDate = Calendar.current.date(byAdding: .hour, value: 12, to: startDate) else {
            print("Could not compute endDate for 12 hours ahead.")
            return
        }
        
        do {
            let hourWeathers = try await weatherService.weather(
                for: location,
                including: .hourly(startDate: startDate, endDate: endDate)
            )
            
            // Filter out hours before 'now' (optional)
            let now = Date()
            let validHours = hourWeathers.filter { $0.date >= now }
            
            // Convert each HourWeather -> HourlyForecast, then take up to 12
            DispatchQueue.main.async {
                self.hourlyForecast = validHours.prefix(12).map { hour in
                    HourlyForecast(
                        time: hour.date,
                        symbolName: hour.symbolName,
                        temperature: hour.temperature.value
                    )
                }
            }
        } catch {
            print("Failed to get hourly forecast data: \(error)")
        }
    }
    // MARK: - Reverse Geocoding
    
    /// Fetches the city name (and ISO code) for a given location, sets `cityName`.
    var locationTimeZone: TimeZone?
    private func fetchCityName(for location: CLLocation) async {
        do {
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let city = placemark.locality ?? "Unknown"
                let isoCode = placemark.isoCountryCode ?? ""

                if !isoCode.isEmpty {
                    self.cityName = "\(city), \(isoCode)"
                } else {
                    self.cityName = city
                }

                // Store the time zone for the location, if available
                if let tz = placemark.timeZone {
                    self.locationTimeZone = tz
                }
            } else {
                self.cityName = "Unknown"
            }
        } catch {
            print("Error reverse geocoding: \(error)")
            self.cityName = "Unknown"
        }
    }
    
    // MARK: - Recent Cities
    
    /// Inserts a new city at the front of recentCities, removing duplicates & limiting to 3.
    private func insertCurrentCityAsFirst(_ city: String) {
        // Skip if "Unknown"
        guard city.lowercased() != "unknown" else { return }
        
        var cities = recentCities.filter { $0.lowercased() != city.lowercased() }
        cities.insert(city, at: 0)
        if cities.count > 3 {
            cities = Array(cities.prefix(3))
        }
        recentCities = cities
        UserDefaults.standard.set(cities, forKey: "RecentSearches")
    }
    
    ///            PrecipitationCardView(dailyPrecipitation: dailyPrecipitation)

    /// Optionally used if you want to manually add a city from somewhere else in your code.
    func addRecentCity(_ city: String) {
        guard city.lowercased() != "unknown" else { return }
        var cities = recentCities.filter { $0.lowercased() != city.lowercased() }
        cities.insert(city, at: 0)
        if cities.count > 3 {
            cities = Array(cities.prefix(3))
        }
        recentCities = cities
        UserDefaults.standard.set(cities, forKey: "RecentSearches")
    }
    
    // MARK: - Daily Forecast
    
    /// Updates `forecastDays` for the next 5 days starting from today.
    private func updateForecast(from weather: Weather) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"  // e.g. "Mon", "Tue"
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Filter daily forecasts so only those from today onward are included
        let forecast = weather.dailyForecast.filter { dayWeather in
            let forecastDay = calendar.startOfDay(for: dayWeather.date)
            return forecastDay >= today
        }
        .prefix(5)
        .compactMap { dayWeather -> ForecastDay? in
            let dayString = formatter.string(from: dayWeather.date)
            return ForecastDay(
                day: dayString,
                iconName: dayWeather.symbolName,
                highTemperature: dayWeather.highTemperature.value
            )
        }
        
        self.forecastDays = Array(forecast)
    }
    
    // MARK: - Widget & Misc
    
    /// Saves user location to the shared container, used by widget extension.
    func saveUserLocation(_ location: CLLocation) {
        let coords = ["lat": location.coordinate.latitude, "lon": location.coordinate.longitude]
        sharedDefaults?.set(coords, forKey: "LastLocation")
        sharedDefaults?.synchronize()
    }
    
    // MARK: - Background Gradient
    // Builds a dynamic gradient based on current weather conditions.
    
    func backgroundGradient() -> LinearGradient {
        guard let weather = weather else {
            // If we have no weather data, default to gray -> black
            return LinearGradient(colors: [Color.black, Color.indigo], startPoint: .top, endPoint: .bottom)
        }
        
        let isDaytime = weather.currentWeather.isDaylight
        let symbol = weather.currentWeather.symbolName.lowercased()
        
        if symbol.contains("drizzle") {
            return isDaytime ?
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.gray.opacity(0.6)]),
                               startPoint: .top, endPoint: .bottom)
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.5)]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("light.rain") {
            return isDaytime ?
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.gray]),
                               startPoint: .top, endPoint: .bottom)
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("heavy.rain") {
            return isDaytime ?
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.gray.opacity(0.4)]),
                               startPoint: .top, endPoint: .bottom)
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.8)]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("rain") {
            return isDaytime ?
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.gray]),
                               startPoint: .top, endPoint: .bottom)
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("snow") {
            return isDaytime ?
                LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.5)]),
                               startPoint: .top, endPoint: .bottom)
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.white.opacity(0.3)]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("sleet") {
            return isDaytime ?
                LinearGradient(gradient: Gradient(colors: [Color.gray, Color.blue.opacity(0.7)]),
                               startPoint: .top, endPoint: .bottom)
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("hail") {
            return isDaytime ?
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.gray]),
                               startPoint: .top, endPoint: .bottom)
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.7)]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("fog") || symbol.contains("mist") {
            return isDaytime ?
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.gray.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("overcast") {
            return isDaytime ?
                LinearGradient(gradient: Gradient(colors: [Color.gray, Color.blue.opacity(0.5)]),
                               startPoint: .top, endPoint: .bottom)
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("wind") {
            return isDaytime ?
                LinearGradient(gradient: Gradient(colors: [Color.mint, Color.blue]),
                               startPoint: .top, endPoint: .bottom)
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.mint.opacity(0.6)]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("cloud.sun") {
            return isDaytime ?
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.gray.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("sun") {
            // Clear / Sunny or partly sunny
            return isDaytime ?
                LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.blue]),
                               startPoint: .top, endPoint: .bottom)
                : LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("thermometer.sun") {
            return isDaytime ?
                LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]),
                               startPoint: .top, endPoint: .bottom)
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.red]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else if symbol.contains("cloud") {
            return isDaytime ?
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.gray.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
                : LinearGradient(gradient: Gradient(colors: [Color.black, Color.indigo]),
                                 startPoint: .top, endPoint: .bottom)
            
        } else {
            return isDaytime ?
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]),
                               startPoint: .top, endPoint: .bottom)
                :   LinearGradient(colors: [Color.black, Color.indigo], startPoint: .top, endPoint: .bottom)
        }
    }
}


