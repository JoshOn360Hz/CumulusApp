import SwiftUI
import WeatherKit
import CoreLocation

struct ForecastDay: Identifiable {
    let id = UUID()
    let day: String
    let iconName: String
    let highTemperature: Double
    let lowTemperature: Double
    let precipitationChance: Double
    let date: Date
}

struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: Date
    let symbolName: String
    let temperature: Double
    let precipitationChance: Double
}
