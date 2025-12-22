//
//  Models.swift
//  CumulusWatch Watch App
//
//  Created by Josh Mansfield on 12/06/2025.
//

import Foundation
import SwiftUI

// Shared weather data model that matches the iOS app
struct SharedWeather: Codable {
    let temperature: Double
    let condition: String
    let symbolName: String
    let isDaytime: Bool
    let location: String
    let windSpeed: Double
    let humidity: Double
    
    let windDirection: Double?
    let feelsLike: Double?
    let visibility: Double?
    let precipitation: Double?
    let pressure: Double?
    let uvIndex: Int?
    let sunrise: String?
    let sunset: String?
}

// Weather Card Types that match the iOS app
enum WeatherCardType: String, CaseIterable, Identifiable, Codable {
    case windDirection = "wind_direction"
    case feelsLike = "feels_like"
    case visibility = "visibility"
    case precipitation = "precipitation"
    case forecast = "forecast"
    case sunTimes = "sun_times"
    case pressure = "pressure"
    case uvIndex = "uv_index"
    case hourlyForecast = "hourly_forecast"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .windDirection: return "Wind Direction"
        case .feelsLike: return "Feels Like"
        case .visibility: return "Visibility"
        case .precipitation: return "Precipitation"
        case .forecast: return "5-Day Forecast"
        case .sunTimes: return "Sun Times"
        case .pressure: return "Pressure"
        case .uvIndex: return "UV Index"
        case .hourlyForecast: return "Hourly Forecast"
        }
    }
    
    var iconName: String {
        switch self {
        case .windDirection: return "location.north.fill"
        case .feelsLike: return "thermometer"
        case .visibility: return "eye.fill"
        case .precipitation: return "drop.fill"
        case .forecast: return "calendar"
        case .sunTimes: return "sunrise.fill"
        case .pressure: return "barometer"
        case .uvIndex: return "sun.max"
        case .hourlyForecast: return "clock"
        }
    }
}
