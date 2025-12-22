//
//  WatchConnectivityManager.swift
//  Cumulus
//
//  Created by Josh Mansfield on 12/06/2025.
//

import Foundation
import WatchConnectivity
import SwiftUI

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var selectedWatchCards: [WeatherCardType] = []
    @Published var isWatchConnected = false
    @Published var isWatchPaired = false
    
    @AppStorage("emulateWatchConnection") var emulateWatchConnection: String = "No" {
        didSet {
            if oldValue != emulateWatchConnection {
                checkPairingState()
                
                #if DEBUG
                print("Watch emulation changed to: \(emulateWatchConnection)")
                #endif
            }
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let watchCardsKey = "selectedWatchCards"
    
    override init() {
        super.init()
        
        loadSelectedCards()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            
            checkPairingState()
        }
    }
    
    private func checkPairingState() {
        if emulateWatchConnection != "No" {
            switch emulateWatchConnection {
            case "Connected":
                isWatchPaired = true
                isWatchConnected = true
            case "Not Paired":
                isWatchPaired = false
                isWatchConnected = false
            default:
                // Use real state as fallback
                let session = WCSession.default
                isWatchPaired = session.isPaired
                isWatchConnected = session.isPaired && session.isReachable
            }
            
            #if DEBUG
            print("EMULATED Watch pairing state: paired=\(isWatchPaired), reachable=\(isWatchConnected)")
            #endif
        } else {
            let session = WCSession.default
            isWatchPaired = session.isPaired
            isWatchConnected = session.isPaired && session.isReachable
            
            #if DEBUG
            print("Watch pairing state: paired=\(session.isPaired), reachable=\(session.isReachable), installed=\(session.isWatchAppInstalled)")
            #endif
        }
    }
    
    // MARK: - Card Management
    
    func updateWatchCards(_ cards: [WeatherCardType]) {
        selectedWatchCards = cards
        saveSelectedCards()
        sendCardsToWatch()
    }
    
    private func loadSelectedCards() {
        if let data = userDefaults.data(forKey: watchCardsKey),
           let cards = try? JSONDecoder().decode([WeatherCardType].self, from: data) {
            selectedWatchCards = cards
        } else {
            // Default cards
            selectedWatchCards = [.windDirection, .feelsLike, .visibility]
        }
    }
    
    private func saveSelectedCards() {
        if let data = try? JSONEncoder().encode(selectedWatchCards) {
            userDefaults.set(data, forKey: watchCardsKey)
        }
    }
    
    // MARK: - Watch Communication
    
    func sendCardsToWatch() {
        if emulateWatchConnection == "Connected" {
            _ = selectedWatchCards.map { $0.rawValue }            
            print("[EMULATED] Successfully sent cards to watch")
            return
        }
        
        //  Connection check
        let session = WCSession.default
        guard session.isPaired && session.isWatchAppInstalled && session.isReachable else { return }
        
        let cardIds = selectedWatchCards.map { $0.rawValue }
        let message = ["selectedCards": cardIds]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send cards to watch: \(error.localizedDescription)")
        }
    }
    
    func sendWeatherToWatch(_ weather: SharedWeather) {
        storeWeatherForWatch(weather)
        if emulateWatchConnection == "Connected" {
            print("[EMULATED] Successfully sent weather to watch")
            return
        }
    let session = WCSession.default
        guard session.isPaired && session.isWatchAppInstalled && session.isReachable else { return }
        
        if let data = try? JSONEncoder().encode(weather) {
            let message = ["weather": data]
            session.sendMessage(message, replyHandler: nil) { error in
                print("Failed to send weather to watch: \(error.localizedDescription)")
            }
        }
    }
    
    func sendUnitsToWatch() {
        if emulateWatchConnection == "Connected" {
            let temperatureUnit = UserDefaults.standard.string(forKey: "temperatureUnit") ?? "system"
            let windSpeedUnit = UserDefaults.standard.string(forKey: "windSpeedUnit") ?? "kmh"
            
            print("[EMULATED] Successfully sent units to watch: temp=\(temperatureUnit), wind=\(windSpeedUnit)")
            return
        }
        
        // Real connection check
        let session = WCSession.default
        guard session.isPaired && session.isWatchAppInstalled && session.isReachable else { return }
        let temperatureUnit = UserDefaults.standard.string(forKey: "temperatureUnit") ?? "system"
        let windSpeedUnit = UserDefaults.standard.string(forKey: "windSpeedUnit") ?? "kmh"
        
        let message = [
            "temperatureUnit": temperatureUnit,
            "windSpeedUnit": windSpeedUnit
        ]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send units to watch: \(error.localizedDescription)")
        }
    }
    
    private func storeWeatherForWatch(_ weather: SharedWeather) {
        if let data = try? JSONEncoder().encode(weather) {
            let defaults = UserDefaults(suiteName: "group.com.josh.cumulus")
            defaults?.set(data, forKey: "currentWeather")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.checkPairingState()
        }
        
        if activationState == .activated && session.isPaired && session.isWatchAppInstalled {
            sendCardsToWatch()
            sendUnitsToWatch()
        }
        
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = false
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = false
            session.activate()
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.checkPairingState()
        }
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.checkPairingState()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any],
                   replyHandler: @escaping ([String : Any]) -> Void) {
        if let request = message["request"] as? String, request == "latestData" {
            var reply: [String: Any] = [:]
            let cardIds = selectedWatchCards.map { $0.rawValue }
            reply["selectedCards"] = cardIds
            reply["temperatureUnit"] = UserDefaults.standard.string(forKey: "temperatureUnit") ?? "system"
            reply["windSpeedUnit"] = UserDefaults.standard.string(forKey: "windSpeedUnit") ?? "kmh"
            if let sharedDefaults = UserDefaults(suiteName: "group.com.josh.cumulus"),
               let data = sharedDefaults.data(forKey: "currentWeather") {
                reply["weather"] = data
            }
            
            replyHandler(reply)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message from watch: \(message)")
    }
}
