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
            location: "London"
        ))
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let dummyWeather = SharedWeather(
            temperature: 23.0,
            condition: "Partly Cloudy",
            symbolName: "cloud.sun",
            isDaytime: true,
            location: "London"
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
            location: "London"
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
