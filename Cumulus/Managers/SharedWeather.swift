//
//  SharedWeather.swift
//  Cumulus
//
//  Created by Josh Mansfield on 29/05/2025.
//

import Foundation

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
