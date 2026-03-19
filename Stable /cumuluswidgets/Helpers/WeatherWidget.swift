import WidgetKit
import Foundation
import CoreLocation
import WeatherKit

struct WeatherEntry: TimelineEntry {
    let date: Date
    let weather: SharedWeather?
}

struct WeatherProvider: TimelineProvider {
    private let appGroupID = "group.com.josh.cumulus"
    private let weatherService = WeatherService()

    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), weather: fallbackWeather)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let weather = loadWeatherFromSharedDefaults() ?? fallbackWeather
        completion(WeatherEntry(date: Date(), weather: weather))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        let refreshInterval = widgetRefreshInterval()

        Task {
            let cachedWeather = loadWeatherFromSharedDefaults() ?? fallbackWeather
            let weather = await fetchLatestWeather(usingFallback: cachedWeather) ?? cachedWeather

            let entry = WeatherEntry(date: Date(), weather: weather)
            let nextRefresh: Date

            if refreshInterval > 0 {
                nextRefresh = Date().addingTimeInterval(TimeInterval(refreshInterval * 60))
            } else {
                nextRefresh = Date().addingTimeInterval(60 * 60 * 12)
            }

            let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
            completion(timeline)
        }
    }

    private var fallbackWeather: SharedWeather {
        SharedWeather(
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
    }

    private func widgetRefreshInterval() -> Int {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let value = defaults.object(forKey: "widgetRefreshInterval") as? Int else {
            return 30
        }

        return value
    }

    private func loadWeatherFromSharedDefaults() -> SharedWeather? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: "currentWeather") else {
            return nil
        }

        return try? JSONDecoder().decode(SharedWeather.self, from: data)
    }

    private func saveWeatherToSharedDefaults(_ weather: SharedWeather) {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = try? JSONEncoder().encode(weather) else {
            return
        }

        defaults.set(data, forKey: "currentWeather")
    }

    private func loadWidgetLocation() -> CLLocation? {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            return nil
        }

        if let latitude = defaults.object(forKey: "widget_location_latitude") as? CLLocationDegrees,
           let longitude = defaults.object(forKey: "widget_location_longitude") as? CLLocationDegrees {
            return CLLocation(latitude: latitude, longitude: longitude)
        }

        if let savedLocation = defaults.dictionary(forKey: "LastLocation"),
           let latitude = savedLocation["lat"] as? CLLocationDegrees,
           let longitude = savedLocation["lon"] as? CLLocationDegrees {
            return CLLocation(latitude: latitude, longitude: longitude)
        }

        return nil
    }

    private func fetchLatestWeather(usingFallback fallback: SharedWeather) async -> SharedWeather? {
        guard let location = loadWidgetLocation() else {
            return nil
        }

        do {
            let weather = try await weatherService.weather(for: location)

            let firstDay = weather.dailyForecast.first
            var sunriseString: String?
            var sunsetString: String?

            if let sunrise = firstDay?.sun.sunrise, let sunset = firstDay?.sun.sunset {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                sunriseString = formatter.string(from: sunrise)
                sunsetString = formatter.string(from: sunset)
            }

            let precipitation = firstDay?.precipitationAmountByType.precipitation.value

            let latestWeather = SharedWeather(
                temperature: weather.currentWeather.temperature.converted(to: UnitTemperature.celsius).value,
                condition: weather.currentWeather.condition.description,
                symbolName: weather.currentWeather.symbolName,
                isDaytime: weather.currentWeather.isDaylight,
                location: fallback.location,
                windSpeed: weather.currentWeather.wind.speed.value,
                humidity: weather.currentWeather.humidity,
                windDirection: weather.currentWeather.wind.direction.value,
                feelsLike: weather.currentWeather.apparentTemperature.converted(to: UnitTemperature.celsius).value,
                visibility: weather.currentWeather.visibility.value,
                precipitation: precipitation,
                pressure: weather.currentWeather.pressure.value,
                uvIndex: weather.currentWeather.uvIndex.value,
                sunrise: sunriseString,
                sunset: sunsetString
            )

            saveWeatherToSharedDefaults(latestWeather)
            return latestWeather
        } catch {
            return nil
        }
    }
}
