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
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .windDirection: return "Wind Direction"
        case .feelsLike: return "Feels Like"
        case .visibility: return "Visibility"
        case .precipitation: return "Precipitation"
        case .forecast: return "5-Day Forecast"
        case .sunTimes: return "Sun Times"
        case .pressure: return "Pressure"
        case .uvIndex: return "UV Index"
        case .hourlyForecast: return "Hourly Forecast"
        }
    }
    
    var iconName: String {
        switch self {
        case .windDirection: return "location.north.fill"
        case .feelsLike: return "thermometer"
        case .visibility: return "eye.fill"
        case .precipitation: return "drop.fill"
        case .forecast: return "calendar"
        case .sunTimes: return "sunrise.fill"
        case .pressure: return "gauge"
        case .uvIndex: return "sun.max"
        case .hourlyForecast: return "clock"
        }
    }
    
    var isSmallCard: Bool {
        switch self {
        case .windDirection, .feelsLike, .visibility, .precipitation, .pressure, .uvIndex:
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
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .windAndFeels: return "Wind & Feels Like"
        case .visibilityAndPrecipitation: return "Visibility & Precipitation"
        case .pressureAndUV: return "Pressure & UV Index"
        case .hourlyForecast: return "Hourly Forecast"
        case .forecast: return "5-Day Forecast"
        case .sunTimes: return "Sun Times"
        }
    }
    
    var iconNames: [String] {
        switch self {
        case .windAndFeels: return ["location.north.fill", "thermometer"]
        case .visibilityAndPrecipitation: return ["eye.fill", "drop.fill"]
        case .pressureAndUV: return ["gauge", "sun.max"]
        case .hourlyForecast: return ["clock"]
        case .forecast: return ["calendar"]
        case .sunTimes: return ["sunrise.fill"]
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
        }
    }
    
    var isSmallGroup: Bool {
        switch self {
        case .windAndFeels, .visibilityAndPrecipitation, .pressureAndUV:
            return true
        case .hourlyForecast, .forecast, .sunTimes:
            return false
        }
    }
}



class WeatherCardManager: ObservableObject {
    @AppStorage("weatherCardGroupOrder") private var cardGroupOrderData: Data = Data()
    
    @Published var cardGroupOrder: [WeatherCardGroup] = []
    
    private let defaultGroupOrder: [WeatherCardGroup] = [
        .windAndFeels,
        .hourlyForecast,
        .visibilityAndPrecipitation,
        .forecast,
        .sunTimes,
        .pressureAndUV
    ]
    
    init() {
        loadCardGroupOrder()
        
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
        saveCardGroupOrder()
    }
    
    func getCardSections() -> [CardSection] {
        var sections: [CardSection] = []
        
        for group in cardGroupOrder {
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
