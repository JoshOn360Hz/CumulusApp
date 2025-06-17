//
//  Helpers.swift
//  CumulusWatch Watch App
//
//  Created by Josh Mansfield on 12/06/2025.
//

import SwiftUI

// Weather icon helper (same as iOS app)
func getWeatherIcon(for symbol: String) -> String {
    let lowerSymbol = symbol.lowercased()
    
    switch lowerSymbol {
            case "moon", "moon.stars":
                return "moon.stars"
        case "sun.max", "sun.max.fill":
            return "sun.max.fill"
        case "cloud.sun", "cloud.sun.fill":
            return "cloud.sun.fill"
        case "moon.fill":
            return "moon.fill"
        case "Drizzle", "cloud.drizzle":
            return "cloud.drizzle"
        case "cloud.moon", "cloud.moon.fill":
            return "cloud.moon.fill"
        case "cloud", "cloud.fill":
            return "cloud.fill"
        case "cloud.rain", "cloud.rain.fill":
            return "cloud.rain.fill"
        case "snow", "snowflake":
            return "snowflake"
        case "cloud.fog", "cloud.fog.fill":
            return "cloud.fog.fill"
        case "wind":
            return "wind"
        case "cloud.hail", "cloud.hail.fill":
            return "cloud.hail.fill"
        case "overcast", "overcast.fill":
                return "cloud.fill"
        case "hail", "hail.fill":
            return "cloud.hail.fill"
        case "sleet", "sleet.fill":
             return "cloud.sleet.fill"
        case "drizzle", "cloud.drizzle.fill":
            return "cloud.drizzle.fill"
        case "light rain", "light.rain.fill":
            return "cloud.rain.fill"
        case "heavy rain", "heavy.rain.fill","cloud.heavyrain.fill","cloud.heavyrain":
            return "cloud.rain.fill"
        case "rain", "rain.fill":
            return "cloud.rain.fill"
        default:
            return "cloud.fill"
    }
}

// Gradient helper (same logic as iOS app)
func backgroundGradient(for symbol: String, isDaytime: Bool) -> LinearGradient {
    let lower = symbol.lowercased()
    
       if lower.contains("drizzle") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.gray.opacity(0.6)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom)

    } else if lower.contains("light.rain") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.gray], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.blue], startPoint: .top, endPoint: .bottom)

    } else if lower.contains("heavy.rain") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.gray.opacity(0.4)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.blue.opacity(0.8)], startPoint: .top, endPoint: .bottom)

    } else if lower.contains("rain") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.gray], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.gray, Color.blue], startPoint: .top, endPoint: .bottom)
    }
    else if symbol.contains("thermometer.sun") {
       return isDaytime ?
           LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]),
                          startPoint: .top, endPoint: .bottom)
           : LinearGradient(gradient: Gradient(colors: [Color.black, Color.red]),
                            startPoint: .top, endPoint: .bottom)
       
   } else if symbol.contains("cloud") {
       return isDaytime ?
       LinearGradient(
           gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.gray.opacity(0.6)]),
           startPoint: .top,
           endPoint: .bottom
       )
           : LinearGradient(colors: [Color.black, Color.indigo], startPoint: .top, endPoint: .bottom)
       
   } else if symbol.contains("wind") {
       return isDaytime ?
           LinearGradient(gradient: Gradient(colors: [Color.mint, Color.blue]),
                          startPoint: .top, endPoint: .bottom)
           : LinearGradient(gradient: Gradient(colors: [Color.black, Color.mint.opacity(0.6)]),
                            startPoint: .top, endPoint: .bottom)
       
   } else if symbol.contains("cloud.sun") {
       return isDaytime ?
           LinearGradient(gradient: Gradient(colors: [Color.gray, Color.blue]),
                          startPoint: .top, endPoint: .bottom)
           : LinearGradient(colors: [Color.black, Color.indigo], startPoint: .top, endPoint: .bottom)
       
   }

    return isDaytime ?
        LinearGradient(colors: [Color.blue.opacity(0.7), Color.cyan], startPoint: .top, endPoint: .bottom) :
        LinearGradient(colors: [Color.black, Color.indigo], startPoint: .top, endPoint: .bottom)

}

// Helper function to format temperature based on user preferences
func formatTemperature(_ rawTemp: Double) -> String {
    let savedUnit = WatchConnectivityManager.shared.temperatureUnit
    
    let isFahrenheit = switch savedUnit {
        case "fahrenheit": true
        case "celsius": false
        default:
            Locale.current.measurementSystem != .metric
    }

    let temp = isFahrenheit ? (rawTemp * 9 / 5) + 32 : rawTemp
    return "\(Int(round(temp)))°\(isFahrenheit ? "F" : "C")"
}

// Helper function to format wind speed based on user preferences
func formatWindSpeed(_ speed: Double) -> String {
    let savedUnit = WatchConnectivityManager.shared.windSpeedUnit
    
    switch savedUnit {
    case "mph":
        let mph = speed * 0.621371
        return "\(Int(round(mph))) mph"
    case "ms":
        let ms = speed / 3.6
        return "\(Int(round(ms))) m/s"
    case "knots":
        let knots = speed * 0.539957
        return "\(Int(round(knots))) kts"
    default: // kmh
        return "\(Int(round(speed))) km/h"
    }
}
