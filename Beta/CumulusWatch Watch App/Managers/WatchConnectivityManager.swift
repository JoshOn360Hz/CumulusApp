//
//  WatchConnectivityManager.swift
//  CumulusWatch Watch App
//
//  Created by Josh Mansfield on 12/06/2025.
//

import Foundation
import WatchConnectivity
import SwiftUI
import Combine

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var selectedCards: [WeatherCardType] = []
    @Published var currentWeather: SharedWeather?
    @Published var temperatureUnit: String = "system"
    @Published var windSpeedUnit: String = "kmh"
    
    private let userDefaults = UserDefaults.standard
    
    override init() {
        super.init()
        
        // Set up WatchConnectivity if supported
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        // Load default values or saved values from UserDefaults
        loadSavedSettings()
        
        // Set default cards if there are none selected
        if selectedCards.isEmpty {
            selectedCards = [.windDirection, .feelsLike, .visibility]
        }
    }
    
    private func loadSavedSettings() {
        // Load saved temperature and wind speed units
        temperatureUnit = userDefaults.string(forKey: "temperatureUnit") ?? "system"
        windSpeedUnit = userDefaults.string(forKey: "windSpeedUnit") ?? "kmh"
        
        // Load saved cards
        if let cardData = userDefaults.data(forKey: "selectedWatchCards"),
           let cards = try? JSONDecoder().decode([String].self, from: cardData) {
            selectedCards = cards.compactMap { WeatherCardType(rawValue: $0) }
        }
        
        // Try to load weather data from shared container if exists
        if let sharedDefaults = UserDefaults(suiteName: "group.com.josh.cumulus"),
           let weatherData = sharedDefaults.data(forKey: "currentWeather"),
           let weather = try? JSONDecoder().decode(SharedWeather.self, from: weatherData) {
            self.currentWeather = weather
        }
    }
    
    private func saveSettings() {
        userDefaults.set(temperatureUnit, forKey: "temperatureUnit")
        userDefaults.set(windSpeedUnit, forKey: "windSpeedUnit")
        
        // Save selected cards
        if let cardData = try? JSONEncoder().encode(selectedCards.map { $0.rawValue }) {
            userDefaults.set(cardData, forKey: "selectedWatchCards")
        }
    }
    
    // Function to request latest data from phone
    func requestLatestDataFromPhone() {
        guard WCSession.default.isReachable else {
            print("Phone is not reachable")
            return
        }
        
        let message = ["request": "latestData"]
        
        WCSession.default.sendMessage(message, replyHandler: { reply in
            DispatchQueue.main.async {
                // Handle selected cards update
                if let cardIds = reply["selectedCards"] as? [String] {
                    self.selectedCards = cardIds.compactMap { rawValue in
                        WeatherCardType(rawValue: rawValue)
                    }
                    // Save the updated cards
                    self.saveSettings()
                }
                
                // Handle weather data update
                if let weatherData = reply["weather"] as? Data,
                   let weather = try? JSONDecoder().decode(SharedWeather.self, from: weatherData) {
                    self.currentWeather = weather
                }
                
                // Handle units update
                if let tempUnit = reply["temperatureUnit"] as? String {
                    self.temperatureUnit = tempUnit
                    self.userDefaults.set(tempUnit, forKey: "temperatureUnit")
                }
                
                if let windUnit = reply["windSpeedUnit"] as? String {
                    self.windSpeedUnit = windUnit
                    self.userDefaults.set(windUnit, forKey: "windSpeedUnit")
                }
            }
        }, errorHandler: { error in
            print("Error requesting data from phone: \(error.localizedDescription)")
        })
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            print("Watch connectivity activated: \(activationState.rawValue)")
            
            // Request latest data when activated
            if activationState == .activated {
                self.requestLatestDataFromPhone()
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            // Handle selected cards update
            if let cardIds = message["selectedCards"] as? [String] {
                self.selectedCards = cardIds.compactMap { rawValue in
                    WeatherCardType(rawValue: rawValue)
                }
                // Save the cards
                self.saveSettings()
            }
            
            // Handle weather data update
            if let weatherData = message["weather"] as? Data,
               let weather = try? JSONDecoder().decode(SharedWeather.self, from: weatherData) {
                self.currentWeather = weather
            }
            
            // Handle units update
            if let tempUnit = message["temperatureUnit"] as? String {
                self.temperatureUnit = tempUnit
                self.userDefaults.set(tempUnit, forKey: "temperatureUnit")
            }
            
            if let windUnit = message["windSpeedUnit"] as? String {
                self.windSpeedUnit = windUnit
                self.userDefaults.set(windUnit, forKey: "windSpeedUnit")
            }
        }
    }
}
