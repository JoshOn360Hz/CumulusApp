import SwiftUI
import WeatherKit
import CoreLocation



@MainActor
class WeatherViewModel: ObservableObject {
    @Published var airQualityIndex: Int? = nil
    @Published var weather: Weather?
    @Published var cityName: String = "Loading..."
    @Published var forecastDays: [ForecastDay] = []
    @Published var hourlyForecast: [HourlyForecast] = []
    @Published var recentCities: [String] = []
    private let sharedDefaults = UserDefaults(suiteName: "group.com.josh.cumulus")
    private let weatherService = WeatherService()
    
    
    
    init() {
        let savedCities = UserDefaults.standard.stringArray(forKey: "RecentSearches") ?? []
        if savedCities.isEmpty {
            recentCities = []
            UserDefaults.standard.set(recentCities, forKey: "RecentSearches")
        } else {
            recentCities = savedCities
        }
    }
    
    

    func fetchWeather(for location: CLLocation) async {
        do {
            let weather = try await weatherService.weather(for: location)
            self.weather = weather
            
            await fetchCityName(for: location)
            if !cityName.isEmpty && cityName != "Unknown" {
                insertCurrentCityAsFirst(cityName)
            }
            
            updateForecast(from: weather)
            await fetchHourlyForecast(for: location)
            let coords = ["lat": location.coordinate.latitude, "lon": location.coordinate.longitude]
            sharedDefaults?.set(coords, forKey: "LastLocation")
            sharedDefaults?.synchronize()
            
        } catch {
            print("Error fetching weather: \(error)")
        }
    }
    
    
    func fetchHourlyForecast(for location: CLLocation) async {
        do {
            let forecast = try await HourlyForecastHelper.fetchNext12Hours(using: weatherService, for: location)
            DispatchQueue.main.async {
                self.hourlyForecast = forecast
            }
        } catch {
            print("Failed to get hourly forecast data: \(error)")
        }
    }
    
    var locationTimeZone: TimeZone?

    
    private func fetchCityName(for location: CLLocation) async {
        let result = await ReverseGeocodingHelper.fetchCityDetails(for: location)
        self.cityName = result.cityName
        self.locationTimeZone = result.timeZone
    }
    
    
    private func insertCurrentCityAsFirst(_ city: String) {
        guard city.lowercased() != "unknown" else { return }
        var cities = recentCities.filter { $0.lowercased() != city.lowercased() }
        cities.insert(city, at: 0)
        if cities.count > 3 {
            cities = Array(cities.prefix(3))
        }
        recentCities = cities
        UserDefaults.standard.set(cities, forKey: "RecentSearches")
    }
    
    
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
    
    
    private func updateForecast(from weather: Weather) {
        self.forecastDays = DailyForecastHelper.extractNext5Days(from: weather)
    }
    
    
    
    
    
    func saveUserLocation(_ location: CLLocation) {
        let coords = ["lat": location.coordinate.latitude, "lon": location.coordinate.longitude]
        sharedDefaults?.set(coords, forKey: "LastLocation")
        sharedDefaults?.synchronize()
    }
    
    
    func backgroundGradient() -> LinearGradient {
        return gradientForWeather(weather)
    }
}
