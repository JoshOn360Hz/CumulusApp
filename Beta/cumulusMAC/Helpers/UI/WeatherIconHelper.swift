import SwiftUI
import WeatherKit

// MARK: - Weather Icon Helper
/// A helper function to map WeatherKit's symbolName to an SF Symbol you want to display.
func getWeatherIcon(for symbol: String) -> String {
    switch symbol {
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
