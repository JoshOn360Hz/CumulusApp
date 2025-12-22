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

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium,.systemLarge])
        .contentMarginsDisabled()
        .configurationDisplayName("Weather Snapshot")
        .description("Shows the current temp and condition.")
    }
}

