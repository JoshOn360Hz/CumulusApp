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
    var locationTimeZone: TimeZone?
    private let weatherService = WeatherService()
    
    
    init() {
        recentCities = UserDefaultsHelper.loadRecentCities()
    }
    
    func fetchWeather(for location: CLLocation) async {
        do {
            let weather = try await weatherService.weather(for: location)
            self.weather = weather
            let locationInfo = await LocationHelper.fetchCityName(for: location)
            self.cityName = locationInfo.cityName
            self.locationTimeZone = locationInfo.timeZone
            if !cityName.isEmpty && cityName != "Unknown" {
                recentCities = UserDefaultsHelper.insertCityAsFirst(cityName, into: recentCities)
            }
            
            forecastDays = ForecastHelper.createForecastDays(from: weather)
            
            await fetchHourlyForecast(for: location)
            
            UserDefaultsHelper.saveLastLocation(location)
            
        } catch {
            print("Error fetching weather: \(error)")
        }
    }
        
    func fetchHourlyForecast(for location: CLLocation) async {
        let startDate = Date()
        guard let endDate = Calendar.current.date(byAdding: .hour, value: 12, to: startDate) else {
            print("Could not compute endDate for 12 hours ahead.")
            return
        }
        
        do {
            let hourForecast = try await weatherService.weather(
                for: location,
                including: .hourly(startDate: startDate, endDate: endDate)
            )
            
            let hourWeathersArray = hourForecast.forecast
            DispatchQueue.main.async {
                self.hourlyForecast = ForecastHelper.createHourlyForecasts(from: hourWeathersArray)
            }
        } catch {
            print("Failed to get hourly forecast data: \(error)")
        }
    }
    
    func addRecentCity(_ city: String) {
        recentCities = UserDefaultsHelper.insertCityAsFirst(city, into: recentCities)
    }
    
    
    func backgroundGradient() -> LinearGradient {
        return GradientHelper.backgroundGradient(self.weather)
    }
}
