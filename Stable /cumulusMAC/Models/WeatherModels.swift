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
