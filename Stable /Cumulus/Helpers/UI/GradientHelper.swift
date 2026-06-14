import SwiftUI
import WeatherKit

func gradientForWeather(_ weather: Weather?) -> LinearGradient {
    guard let weather = weather else {
        return LinearGradient(
            colors: [Color(red: 0.05, green: 0.05, blue: 0.2), Color(red: 0.1, green: 0.05, blue: 0.35)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    let isDaytime = weather.currentWeather.isDaylight
    let symbol = weather.currentWeather.symbolName.lowercased()

    if symbol.contains("tornado") || symbol.contains("hurricane") {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.25, green: 0.2, blue: 0.3), Color(red: 0.35, green: 0.15, blue: 0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(red: 0.05, green: 0.04, blue: 0.1), Color(red: 0.15, green: 0.08, blue: 0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)

    } else if symbol.contains("thunderstorm") || symbol.contains("lightning") {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.15, green: 0.15, blue: 0.3), Color(red: 0.3, green: 0.25, blue: 0.45), Color(red: 0.18, green: 0.12, blue: 0.2)], startPoint: .top, endPoint: .bottom)
            : LinearGradient(colors: [Color(red: 0.04, green: 0.04, blue: 0.12), Color(red: 0.12, green: 0.1, blue: 0.25), Color(red: 0.05, green: 0.04, blue: 0.1)], startPoint: .top, endPoint: .bottom)

    } else if symbol.contains("heavy.rain") {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.2, green: 0.28, blue: 0.45), Color(red: 0.3, green: 0.35, blue: 0.5), Color(red: 0.15, green: 0.2, blue: 0.35)], startPoint: .top, endPoint: .bottom)
            : LinearGradient(colors: [Color(red: 0.04, green: 0.06, blue: 0.14), Color(red: 0.08, green: 0.12, blue: 0.25)], startPoint: .top, endPoint: .bottom)

    } else if symbol.contains("rain") || symbol.contains("drizzle") {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.3, green: 0.4, blue: 0.6), Color(red: 0.4, green: 0.45, blue: 0.6), Color(red: 0.25, green: 0.3, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(red: 0.05, green: 0.08, blue: 0.18), Color(red: 0.1, green: 0.15, blue: 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)

    } else if symbol.contains("snow") || symbol.contains("blizzard") {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.65, green: 0.75, blue: 0.9), Color(red: 0.8, green: 0.87, blue: 0.98), Color(red: 0.55, green: 0.68, blue: 0.85)], startPoint: .top, endPoint: .bottom)
            : LinearGradient(colors: [Color(red: 0.08, green: 0.1, blue: 0.22), Color(red: 0.15, green: 0.18, blue: 0.35), Color(red: 0.2, green: 0.22, blue: 0.38)], startPoint: .top, endPoint: .bottom)

    } else if symbol.contains("sleet") || symbol.contains("hail") {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.45, green: 0.5, blue: 0.65), Color(red: 0.35, green: 0.42, blue: 0.58)], startPoint: .top, endPoint: .bottom)
            : LinearGradient(colors: [Color(red: 0.06, green: 0.07, blue: 0.18), Color(red: 0.12, green: 0.14, blue: 0.28)], startPoint: .top, endPoint: .bottom)

    } else if symbol.contains("fog") || symbol.contains("mist") || symbol.contains("haze") {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.65, green: 0.68, blue: 0.75), Color(red: 0.72, green: 0.74, blue: 0.8), Color(red: 0.58, green: 0.62, blue: 0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(red: 0.08, green: 0.09, blue: 0.16), Color(red: 0.15, green: 0.16, blue: 0.25)], startPoint: .top, endPoint: .bottom)

    } else if symbol.contains("overcast") {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.42, green: 0.48, blue: 0.62), Color(red: 0.52, green: 0.56, blue: 0.68), Color(red: 0.38, green: 0.44, blue: 0.58)], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(red: 0.07, green: 0.08, blue: 0.16), Color(red: 0.12, green: 0.14, blue: 0.24)], startPoint: .top, endPoint: .bottom)

    } else if symbol.contains("cloud.sun") || (symbol.contains("cloud") && symbol.contains("sun")) {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.3, green: 0.55, blue: 0.85), Color(red: 0.5, green: 0.68, blue: 0.92), Color(red: 0.45, green: 0.6, blue: 0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(red: 0.06, green: 0.08, blue: 0.2), Color(red: 0.12, green: 0.15, blue: 0.32)], startPoint: .top, endPoint: .bottom)

    } else if symbol.contains("cloud") {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.35, green: 0.5, blue: 0.75), Color(red: 0.48, green: 0.6, blue: 0.82), Color(red: 0.3, green: 0.45, blue: 0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(red: 0.05, green: 0.07, blue: 0.18), Color(red: 0.1, green: 0.12, blue: 0.28)], startPoint: .top, endPoint: .bottom)

    } else if symbol.contains("wind") {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.25, green: 0.72, blue: 0.75), Color(red: 0.2, green: 0.55, blue: 0.82)], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(red: 0.04, green: 0.12, blue: 0.22), Color(red: 0.06, green: 0.18, blue: 0.3)], startPoint: .top, endPoint: .bottom)

    } else if symbol.contains("thermometer.sun") || symbol.contains("hot") {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.95, green: 0.45, blue: 0.1), Color(red: 1.0, green: 0.6, blue: 0.1), Color(red: 0.85, green: 0.3, blue: 0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(red: 0.2, green: 0.05, blue: 0.0), Color(red: 0.35, green: 0.08, blue: 0.02)], startPoint: .top, endPoint: .bottom)

    } else if symbol.contains("sun") {
        // Clear day: vivid sky blue → deep azure
        return isDaytime
            ? LinearGradient(
                colors: [Color(red: 0.1, green: 0.5, blue: 0.92), Color(red: 0.2, green: 0.65, blue: 0.98), Color(red: 0.05, green: 0.38, blue: 0.82)],
                startPoint: .topLeading, endPoint: .bottomTrailing
              )
            // Clear night: deep navy → rich indigo
            : LinearGradient(
                colors: [Color(red: 0.03, green: 0.04, blue: 0.18), Color(red: 0.06, green: 0.08, blue: 0.3), Color(red: 0.1, green: 0.06, blue: 0.22)],
                startPoint: .topLeading, endPoint: .bottomTrailing
              )

    } else {
        return isDaytime
            ? LinearGradient(colors: [Color(red: 0.15, green: 0.5, blue: 0.9), Color(red: 0.1, green: 0.6, blue: 0.95)], startPoint: .top, endPoint: .bottom)
            : LinearGradient(colors: [Color(red: 0.04, green: 0.04, blue: 0.18), Color(red: 0.08, green: 0.07, blue: 0.28)], startPoint: .top, endPoint: .bottom)
    }
}
