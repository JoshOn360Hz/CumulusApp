//
//  DailyForecastHelper.swift
//  Cumulus
//
//  Created by Josh Mansfield on 11/06/2025.
//

import Foundation
import WeatherKit

struct DailyForecastHelper {
    static func extractNext5Days(from weather: Weather) -> [ForecastDay] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" 
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return weather.dailyForecast
            .filter { calendar.startOfDay(for: $0.date) >= today }
            .prefix(5)
            .compactMap { dayWeather in
                ForecastDay(
                    day: formatter.string(from: dayWeather.date),
                    iconName: dayWeather.symbolName,
                    highTemperature: dayWeather.highTemperature.value
                )
            }
    }
}
