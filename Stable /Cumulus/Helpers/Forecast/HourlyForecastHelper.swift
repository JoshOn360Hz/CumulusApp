//
//  HourlyForecastHelper.swift
//  Cumulus
//
//  Created by Josh Mansfield on 11/06/2025.
//

import Foundation
import CoreLocation
import WeatherKit

struct HourlyForecastHelper {
    static func fetchNext24Hours(
        using service: WeatherService,
        for location: CLLocation
    ) async throws -> [HourlyForecast] {
        let startDate = Date()
        guard let endDate = Calendar.current.date(byAdding: .hour, value: 25, to: startDate) else {
            throw NSError(domain: "HourlyForecastHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not compute endDate for 25 hours ahead."])
        }
        
        let hourWeathers = try await service.weather(
            for: location,
            including: .hourly(startDate: startDate, endDate: endDate)
        )
        
        let now = Date()
        let validHours = hourWeathers.filter { $0.date >= now }

        return validHours.prefix(24).map { hour in
            HourlyForecast(
                time: hour.date,
                symbolName: hour.symbolName,
                temperature: hour.temperature.value,
                precipitationChance: hour.precipitationChance,
                windSpeed: hour.wind.speed.converted(to: .kilometersPerHour).value
            )
        }
    }
}
