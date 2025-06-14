//
//  CumulusWidgets.swift
//  Cumulus
//
//  Created by Josh Mansfield on 29/05/2025.
//
import SwiftUI
import WidgetKit
@main
struct CumulusWidgets: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
    }
}


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), weather: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        completion(WeatherEntry(date: Date(), weather: nil))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        let weather = loadWeather()
        let entry = WeatherEntry(date: Date(), weather: weather)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadWeather() -> SharedWeather? {
        if let data = UserDefaults(suiteName: "group.com.josh.cumulus")?.data(forKey: "currentWeather") {
            return try? JSONDecoder().decode(SharedWeather.self, from: data)
        }
        return nil
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium,.systemLarge])
        .contentMarginsDisabled()
        .configurationDisplayName("Weather Snapshot")
        .description("Shows the current temp and condition.")
    }
}

