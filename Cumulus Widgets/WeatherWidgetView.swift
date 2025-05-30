import SwiftUI
import WidgetKit

struct WeatherWidgetView: View {
    let entry: WeatherEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let weather = entry.weather {
            widgetBody(for: weather)
        } else {
            let fallback = SharedWeather(
                temperature: 14.0,
                condition: "Mostly Clear",
                symbolName: "moon.stars",
                isDaytime: false,
                location: "London"
            )
            widgetBody(for: fallback)
        }
    }

    @ViewBuilder
    func widgetBody(for weather: SharedWeather) -> some View {
        ZStack {
            backgroundGradient(for: weather.symbolName, isDaytime: weather.isDaytime)

            switch family {
            case .systemSmall:
                VStack(spacing: 4) {
                    Image(systemName: getWeatherIcon(for: weather.symbolName))
                        .font(.system(size: 30))
                        .foregroundColor(.white)

                    Text("\(Int(weather.temperature))°")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(weather.condition)
                        .font(.caption)
                        .foregroundColor(.white)
                }

            case .systemMedium:
                VStack(spacing: 8) {
                    Text(weather.location)
                        .font(.caption)
                        .foregroundColor(.white)

                    Text("\(Int(weather.temperature))°")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)

                    Text(weather.condition)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }

            default:
                Text("Unsupported Size")
                    .foregroundColor(.white)
            }
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}
