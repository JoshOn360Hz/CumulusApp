//
//  ForecastDay.swift
//  Cumulus
//
//  Created by Josh Mansfield on 12/06/2025.
//

import SwiftUI
import WeatherKit
import CoreLocation

// MARK: - Models

struct ForecastDay: Identifiable {
    let id = UUID()
    let day: String
    let iconName: String
    let highTemperature: Double
}
