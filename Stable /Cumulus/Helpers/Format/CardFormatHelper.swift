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

// Convert wind speed in m/s to Beaufort scale (0-12)
func windSpeedToBeaufort(_ speedInMetersPerSecond: Double) -> Int {
    switch speedInMetersPerSecond {
    case 0..<0.5: return 0
    case 0.5..<1.6: return 1
    case 1.6..<3.4: return 2
    case 3.4..<5.5: return 3
    case 5.5..<8.0: return 4
    case 8.0..<10.8: return 5
    case 10.8..<13.9: return 6
    case 13.9..<17.2: return 7
    case 17.2..<20.8: return 8
    case 20.8..<24.5: return 9
    case 24.5..<28.5: return 10
    case 28.5..<32.7: return 11
    default: return 12
    }
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
    case "beaufort":
        let speedInMS = windSpeedMeasurement.converted(to: .metersPerSecond).value
        let beaufortScale = windSpeedToBeaufort(speedInMS)
        return "\(beaufortScale) Bft"
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
