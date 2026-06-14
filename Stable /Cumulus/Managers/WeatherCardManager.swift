//
//  WeatherCardManager.swift
//  Cumulus
//
//  Created by Josh Mansfield on 11/06/2025.
//

import SwiftUI
import WeatherKit



extension Notification.Name {
    static let weatherCardOrderChanged = Notification.Name("weatherCardOrderChanged")
    static let weatherCardVisibilityChanged = Notification.Name("weatherCardVisibilityChanged")
}



enum WeatherCardType: String, CaseIterable, Identifiable, Codable {
    case windDirection = "wind_direction"
    case feelsLike = "feels_like"
    case visibility = "visibility"
    case precipitation = "precipitation"
    case forecast = "forecast"
    case sunTimes = "sun_times"
    case pressure = "pressure"
    case uvIndex = "uv_index"
    case hourlyForecast = "hourly_forecast"
    case humidity = "humidity"
    case dewPoint = "dew_point"
    case cloudCover = "cloud_cover"
    case windGust = "wind_gust"
    case moonPhase = "moon_phase"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .windDirection: return "Wind Direction"
        case .feelsLike: return "Feels Like"
        case .visibility: return "Visibility"
        case .precipitation: return "Precipitation"
        case .forecast: return "10-Day Forecast"
        case .sunTimes: return "Sun Times"
        case .pressure: return "Pressure"
        case .uvIndex: return "UV Index"
        case .hourlyForecast: return "Hourly Forecast"
        case .humidity: return "Humidity"
        case .dewPoint: return "Dew Point"
        case .cloudCover: return "Cloud Cover"
        case .windGust: return "Wind Gust"
        case .moonPhase: return "Moon Phase"
        }
    }

    var iconName: String {
        switch self {
        case .windDirection: return "wind"
        case .feelsLike: return "thermometer.medium"
        case .visibility: return "eye.fill"
        case .precipitation: return "drop.fill"
        case .forecast: return "calendar"
        case .sunTimes: return "sun.horizon.fill"
        case .pressure: return "barometer"
        case .uvIndex: return "sun.max.fill"
        case .hourlyForecast: return "clock"
        case .humidity: return "humidity"
        case .dewPoint: return "thermometer.and.liquid.waves"
        case .cloudCover: return "cloud"
        case .windGust: return "wind"
        case .moonPhase: return "moon.stars"
        }
    }

    var isSmallCard: Bool {
        switch self {
        case .windDirection, .feelsLike, .visibility, .precipitation, .pressure, .uvIndex,
             .humidity, .dewPoint, .cloudCover, .windGust, .moonPhase:
            return true
        case .forecast, .sunTimes, .hourlyForecast:
            return false
        }
    }
}



enum WeatherCardGroup: String, CaseIterable, Identifiable, Codable {
    case windAndFeels = "wind_and_feels"
    case visibilityAndPrecipitation = "visibility_and_precipitation"
    case pressureAndUV = "pressure_and_uv"
    case hourlyForecast = "hourly_forecast"
    case forecast = "forecast"
    case sunTimes = "sun_times"
    case humidityAndDewPoint = "humidity_and_dew_point"
    case cloudAndGust = "cloud_and_gust"
    case moonPhase = "moon_phase"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .windAndFeels: return "Wind & Feels Like"
        case .visibilityAndPrecipitation: return "Visibility & Precipitation"
        case .pressureAndUV: return "Pressure & UV Index"
        case .hourlyForecast: return "Hourly Forecast"
        case .forecast: return "10-Day Forecast"
        case .sunTimes: return "Sun Times"
        case .humidityAndDewPoint: return "Humidity & Dew Point"
        case .cloudAndGust: return "Cloud Cover & Wind Gust"
        case .moonPhase: return "Moon Phase"
        }
    }

    var iconNames: [String] {
        switch self {
        case .windAndFeels: return ["wind", "thermometer.medium"]
        case .visibilityAndPrecipitation: return ["eye.fill", "drop.fill"]
        case .pressureAndUV: return ["barometer", "sun.max.fill"]
        case .hourlyForecast: return ["clock"]
        case .forecast: return ["calendar"]
        case .sunTimes: return ["sun.horizon.fill"]
        case .humidityAndDewPoint: return ["humidity", "thermometer.and.liquid.waves"]
        case .cloudAndGust: return ["cloud", "wind"]
        case .moonPhase: return ["moon.stars"]
        }
    }

    var cards: [WeatherCardType] {
        switch self {
        case .windAndFeels: return [.windDirection, .feelsLike]
        case .visibilityAndPrecipitation: return [.visibility, .precipitation]
        case .pressureAndUV: return [.pressure, .uvIndex]
        case .hourlyForecast: return [.hourlyForecast]
        case .forecast: return [.forecast]
        case .sunTimes: return [.sunTimes]
        case .humidityAndDewPoint: return [.humidity, .dewPoint]
        case .cloudAndGust: return [.cloudCover, .windGust]
        case .moonPhase: return [.moonPhase]
        }
    }

    var isSmallGroup: Bool {
        switch self {
        case .windAndFeels, .visibilityAndPrecipitation, .pressureAndUV,
             .humidityAndDewPoint, .cloudAndGust, .moonPhase:
            return true
        case .hourlyForecast, .forecast, .sunTimes:
            return false
        }
    }
}



class WeatherCardManager: ObservableObject {
    @AppStorage("weatherCardGroupOrder") private var cardGroupOrderData: Data = Data()
    @AppStorage("hiddenCardGroups") private var hiddenCardGroupsData: Data = Data()

    @Published var cardGroupOrder: [WeatherCardGroup] = []
    @Published var hiddenCardGroups: Set<WeatherCardGroup> = []

    private let defaultGroupOrder: [WeatherCardGroup] = [
        .windAndFeels,
        .hourlyForecast,
        .humidityAndDewPoint,
        .visibilityAndPrecipitation,
        .forecast,
        .pressureAndUV,
        .cloudAndGust,
        .sunTimes,
        .moonPhase
    ]

    private let defaultHiddenGroups: Set<WeatherCardGroup> = [.moonPhase]

    init() {
        loadCardGroupOrder()
        loadHiddenGroups()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cardOrderChanged),
            name: .weatherCardOrderChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cardVisibilityChanged),
            name: .weatherCardVisibilityChanged,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func userDefaultsDidChange() {
        let newData = UserDefaults.standard.data(forKey: "weatherCardGroupOrder") ?? Data()
        if newData != cardGroupOrderData {
            DispatchQueue.main.async {
                self.loadCardGroupOrder()
            }
        }
    }

    @objc private func cardOrderChanged() {
        DispatchQueue.main.async {
            self.loadCardGroupOrder()
        }
    }

    @objc private func cardVisibilityChanged() {
        DispatchQueue.main.async {
            self.loadHiddenGroups()
        }
    }

    private func loadCardGroupOrder() {
        let previousOrder = cardGroupOrder

        if let decodedOrder = try? JSONDecoder().decode([WeatherCardGroup].self, from: cardGroupOrderData) {
            var order = decodedOrder
            for group in defaultGroupOrder {
                if !order.contains(group) {
                    order.append(group)
                }
            }
            order = order.filter { defaultGroupOrder.contains($0) }
            if order != previousOrder {
                cardGroupOrder = order
            }
        } else {
            if defaultGroupOrder != previousOrder {
                cardGroupOrder = defaultGroupOrder
            }
        }
    }

    private func loadHiddenGroups() {
        if let decoded = try? JSONDecoder().decode([WeatherCardGroup].self, from: hiddenCardGroupsData) {
            hiddenCardGroups = Set(decoded)
        } else {
            hiddenCardGroups = defaultHiddenGroups
        }
    }

    private func saveHiddenGroups() {
        if let encoded = try? JSONEncoder().encode(Array(hiddenCardGroups)) {
            hiddenCardGroupsData = encoded
            NotificationCenter.default.post(name: .weatherCardVisibilityChanged, object: nil)
        }
    }

    func toggleVisibility(_ group: WeatherCardGroup) {
        if hiddenCardGroups.contains(group) {
            hiddenCardGroups.remove(group)
        } else {
            hiddenCardGroups.insert(group)
        }
        saveHiddenGroups()
    }

    func isVisible(_ group: WeatherCardGroup) -> Bool {
        !hiddenCardGroups.contains(group)
    }

    func saveCardGroupOrder() {
        if let encoded = try? JSONEncoder().encode(cardGroupOrder) {
            cardGroupOrderData = encoded
            NotificationCenter.default.post(name: .weatherCardOrderChanged, object: nil)
        }
    }

    func moveCardGroup(from source: IndexSet, to destination: Int) {
        cardGroupOrder.move(fromOffsets: source, toOffset: destination)
        saveCardGroupOrder()
    }

    func resetToDefault() {
        cardGroupOrder = defaultGroupOrder
        hiddenCardGroups = defaultHiddenGroups
        saveCardGroupOrder()
        saveHiddenGroups()
    }

    func getCardSections() -> [CardSection] {
        var sections: [CardSection] = []

        for group in cardGroupOrder where isVisible(group) {
            if group.isSmallGroup {
                let cards = group.cards
                if cards.count == 2 {
                    sections.append(.smallPair(cards[0], cards[1]))
                } else if cards.count == 1 {
                    sections.append(.singleSmall(cards[0]))
                }
            } else {
                if let card = group.cards.first {
                    sections.append(.large(card))
                }
            }
        }

        return sections
    }
}


enum CardSection: Identifiable {
    case smallPair(WeatherCardType, WeatherCardType)
    case singleSmall(WeatherCardType)
    case large(WeatherCardType)

    var id: String {
        switch self {
        case .smallPair(let card1, let card2):
            return "\(card1.id)_\(card2.id)"
        case .singleSmall(let card):
            return card.id
        case .large(let card):
            return card.id
        }
    }
}
