import SwiftUI
import WeatherKit
import CoreLocation

class ForecastHelper {
    // Updates forecast days for the next 5 days starting from today
    static func createForecastDays(from weather: Weather) -> [ForecastDay] {
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
        
        return Array(forecast)
    }
    
    // Creates hourly forecast objects for the next 12 hours
    static func createHourlyForecasts(from hourWeathers: [HourWeather]) -> [HourlyForecast] {
        // Filter out hours before 'now'
        let now = Date()
        let validHours = hourWeathers.filter { $0.date >= now }
        
        // Convert each HourWeather -> HourlyForecast, then take up to 12
        return validHours.prefix(12).map { hour in
            HourlyForecast(
                time: hour.date,
                symbolName: hour.symbolName,
                temperature: hour.temperature.value
            )
        }
    }
}
