import WidgetKit
import Foundation

struct WeatherEntry: TimelineEntry {
    let date: Date
    let weather: SharedWeather?
}

struct WeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), weather: SharedWeather(
            temperature: 21.0,
            condition: "Sunny",
            symbolName: "sun.max",
            isDaytime: true,
            location: "London",
            windSpeed: 2.0,
            humidity: 0.6,
            windDirection: nil,
            feelsLike: nil,
            visibility: nil,
            precipitation: nil,
            pressure: nil,
            uvIndex: nil,
            sunrise: nil,
            sunset: nil
        ))
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let dummyWeather = SharedWeather(
            temperature: 23.0,
            condition: "Partly Cloudy",
            symbolName: "cloud.sun",
            isDaytime: true,
            location: "London",
            windSpeed: 2.0,
            humidity: 0.6,
            windDirection: 120.0,
            feelsLike: 22.0,
            visibility: 10.0,
            precipitation: 0.0,
            pressure: 1013.0,
            uvIndex: 4,
            sunrise: "06:30",
            sunset: "20:15"
        )

        let entry = WeatherEntry(date: Date(), weather: dummyWeather)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        let weather = loadWeatherFromSharedDefaults() ?? SharedWeather(
            temperature: 21.0,
            condition: "Sunny",
            symbolName: "sun.max",
            isDaytime: true,
            location: "London",
            windSpeed: 2.0,
            humidity: 0.6,
            windDirection: nil,
            feelsLike: nil,
            visibility: nil,
            precipitation: nil,
            pressure: nil,
            uvIndex: nil,
            sunrise: nil,
            sunset: nil
        )

        let entry = WeatherEntry(date: Date(), weather: weather)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 30)))
        completion(timeline)
    }

    // MARK: - Helper to load from shared UserDefaults
    private func loadWeatherFromSharedDefaults() -> SharedWeather? {
        if let defaults = UserDefaults(suiteName: "group.com.josh.cumulus"),
           let data = defaults.data(forKey: "currentWeather"),
           let weather = try? JSONDecoder().decode(SharedWeather.self, from: data) {
            return weather
        }
        return nil
    }
}
