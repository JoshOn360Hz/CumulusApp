//
//  HourlyForecastModel.swift
//  Cumulus
//
//  Created by Josh Mansfield on 12/06/2025.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: Date
    let symbolName: String
    let temperature: Double
}
