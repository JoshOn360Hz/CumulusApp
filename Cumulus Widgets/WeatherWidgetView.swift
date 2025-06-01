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
                location: "London",
                windSpeed: 2.0,       
                humidity: 0.6
            )
            widgetBody(for: fallback)
        }
    }

    @ViewBuilder
    func widgetBody(for weather: SharedWeather) -> some View {
        ZStack {
            backgroundGradient(for: weather.symbolName, isDaytime: weather.isDaytime)

            switch family {
                
// small widget
                
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
                
// medium widget
                
                VStack(spacing: 8) {
                    Text(weather.location.components(separatedBy: ",").first ?? weather.location)
                        .font(.caption)
                        .foregroundColor(.white)

                    Text("\(Int(weather.temperature))°")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)

                    Text(weather.condition)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
            case .systemLarge:
                
// large widget
                
                ZStack {
                    backgroundGradient(for: weather.symbolName, isDaytime: weather.isDaytime)

                    Color.clear

                    // Widget content
                    VStack(spacing: 16) {
                        Text(weather.location.components(separatedBy: ",").first ?? weather.location)
                            .font(.title2)
                            

                        Image(systemName: getWeatherIcon(for: weather.symbolName))
                            .font(.system(size: 60))

                        Text("\(Int(weather.temperature))°")
                            .font(.system(size: 50, weight: .semibold))

                        Text(weather.condition)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))

                        HStack {
                            VStack {
                                Text("Wind")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(Int(weather.windSpeed)) km/h")
                            }
                            Spacer()
                            VStack {
                                Text("Humidity")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(Int(weather.humidity * 100))%")                            }
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding()
                    .foregroundColor(.white.opacity(0.7))

                    .containerBackground(for: .widget) { backgroundGradient(for: weather.symbolName, isDaytime: weather.isDaytime) }
                }
            default:
                Text("Unsupported Size")
                    .foregroundColor(.white)
            }
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}
