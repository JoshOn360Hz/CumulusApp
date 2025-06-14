//
//  cardformathelper.swift
//  Cumulus
//
//  Created by Josh Mansfield on 30/05/2025.
//
import SwiftUI
import WeatherKit

func formatCardTemperature(_ rawTemp: Double) -> String {
    let savedUnit = UserDefaults.standard.string(forKey: "temperatureUnit") ?? "system"
    
    let isFahrenheit = switch savedUnit {
        case "fahrenheit": true
        case "celsius": false
        default:
            Locale.current.measurementSystem != .metric
    }

    let temp = isFahrenheit ? (rawTemp * 9 / 5) + 32 : rawTemp
    return "\(Int(round(temp)))°"
}

func formatWindSpeed(_ windSpeedMeasurement: Measurement<UnitSpeed>) -> String {
    let savedUnit = UserDefaults.standard.string(forKey: "windSpeedUnit") ?? "kmh"
    
    let convertedSpeed: Measurement<UnitSpeed>
    let unitLabel: String
    
    switch savedUnit {
    case "mph":
        convertedSpeed = windSpeedMeasurement.converted(to: .milesPerHour)
        unitLabel = "mph"
    case "ms":
        convertedSpeed = windSpeedMeasurement.converted(to: .metersPerSecond)
        unitLabel = "m/s"
    default:
        convertedSpeed = windSpeedMeasurement.converted(to: .kilometersPerHour)
        unitLabel = "km/h"
    }
    
    return String(format: "%.0f %@", convertedSpeed.value, unitLabel)
}

struct TemperatureUnitRefreshable: ViewModifier {
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "system"
    
    func body(content: Content) -> some View {
        content
            .id(temperatureUnit) // This forces view to refresh when temperatureUnit changes
    }
}

// Helper view modifier to force views to refresh when wind speed unit changes

struct WindSpeedUnitRefreshable: ViewModifier {
    @AppStorage("windSpeedUnit") private var windSpeedUnit: String = "kmh"
    
    func body(content: Content) -> some View {
        content
            .id(windSpeedUnit) // This forces view to refresh when windSpeedUnit changes
    }
}


struct UnitsRefreshable: ViewModifier {
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "system"
    @AppStorage("windSpeedUnit") private var windSpeedUnit: String = "kmh"
    
    func body(content: Content) -> some View {
        content
            .id("\(temperatureUnit)-\(windSpeedUnit)") 
    }
}

extension View {
    func refreshOnTemperatureUnitChange() -> some View {
        modifier(TemperatureUnitRefreshable())
    }
    
    func refreshOnWindSpeedUnitChange() -> some View {
        modifier(WindSpeedUnitRefreshable())
    }
    
    func refreshOnUnitsChange() -> some View {
        modifier(UnitsRefreshable())
    }
}
