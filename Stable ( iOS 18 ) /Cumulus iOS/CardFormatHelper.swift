//
//  cardformathelper.swift
//  Cumulus
//
//  Created by Josh Mansfield on 30/05/2025.
//
import SwiftUI
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
