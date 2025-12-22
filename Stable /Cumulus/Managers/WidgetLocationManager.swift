//
//  WidgetLocationManager.swift
//  Cumulus
//
//  Created by Josh Mansfield on 22/12/2025.
//

import CoreLocation
import WidgetKit
import WeatherKit

class WidgetLocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = WidgetLocationManager()
    
    private let manager = CLLocationManager()
    private let appGroupID = "group.com.josh.cumulus"
    private let weatherService = WeatherService()
    private var lastWeatherFetchDate: Date?
    
    override init() {
        super.init()
        
        manager.delegate = self
        // Not needed for significant location changes, but good to have
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.activityType = .other
        
        // Listen for refresh interval changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshIntervalChanged),
            name: NSNotification.Name("WidgetRefreshIntervalChanged"),
            object: nil
        )
    }
    
    @objc private func refreshIntervalChanged() {
        // Restart monitoring if settings changed
        let status = manager.authorizationStatus
        if status == .authorizedAlways {
            let interval = UserDefaults.standard.integer(forKey: "widgetRefreshInterval")
            if interval == 0 {
                // Turned off
                manager.stopMonitoringSignificantLocationChanges()
            } else {
                // Re-enable
                manager.startMonitoringSignificantLocationChanges()
            }
        }
    }
    
    func setupWidgetLocationManager() {
        // Request Always authorization for background updates
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestAlwaysAuthorization()
        } else if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        
        // Only use significant location changes to avoid showing location indicator
        manager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            // First request When In Use
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            // Then upgrade to Always
            manager.requestAlwaysAuthorization()
        case .denied, .restricted:
            manager.stopMonitoringSignificantLocationChanges()
        case .authorizedAlways:
            // Only use significant location changes (no continuous updates)
            manager.startMonitoringSignificantLocationChanges()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newestLocation = locations.last else { return }
        
        // Check if refresh is enabled
        let refreshInterval = UserDefaults.standard.integer(forKey: "widgetRefreshInterval")
        guard refreshInterval > 0 else {
            print("Widget refresh is disabled")
            return
        }
        
        // Check if enough time has passed since last fetch
        if let lastFetch = lastWeatherFetchDate {
            let minutesSinceLastFetch = Date().timeIntervalSince(lastFetch) / 60
            if minutesSinceLastFetch < Double(refreshInterval) {
                print("Skipping weather fetch - only \(Int(minutesSinceLastFetch)) minutes since last fetch")
                return
            }
        }
        
        // Save location to shared UserDefaults for widget access
        if let sharedDefaults = UserDefaults(suiteName: appGroupID) {
            sharedDefaults.set(newestLocation.coordinate.latitude, forKey: "widget_location_latitude")
            sharedDefaults.set(newestLocation.coordinate.longitude, forKey: "widget_location_longitude")
            sharedDefaults.set(newestLocation.altitude, forKey: "widget_location_altitude")
            sharedDefaults.set(Date(), forKey: "widget_location_timestamp")
        }
        
        // Update last fetch time
        lastWeatherFetchDate = Date()
        
        // Fetch weather data in background
        Task {
            await fetchAndSaveWeatherData(for: newestLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("WidgetLocationManager error: \(error.localizedDescription)")
    }
    
    // MARK: - Weather Fetching
    
    private func fetchAndSaveWeatherData(for location: CLLocation) async {
        do {
            let weather = try await weatherService.weather(for: location)
            let cityName = await fetchCityName(for: location)
            
            // Extract weather data for widget
            let firstDay = weather.dailyForecast.first
            var sunriseStr: String? = nil
            var sunsetStr: String? = nil
            
            if let sunrise = firstDay?.sun.sunrise, let sunset = firstDay?.sun.sunset {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                sunriseStr = formatter.string(from: sunrise)
                sunsetStr = formatter.string(from: sunset)
            }
            
            let precipitation = firstDay?.precipitationAmountByType.precipitation.value
            
            let sharedWeather = SharedWeather(
                temperature: weather.currentWeather.temperature.converted(to: UnitTemperature.celsius).value,
                condition: weather.currentWeather.condition.description,
                symbolName: weather.currentWeather.symbolName,
                isDaytime: weather.currentWeather.isDaylight,
                location: cityName,
                windSpeed: weather.currentWeather.wind.speed.value,
                humidity: weather.currentWeather.humidity,
                windDirection: weather.currentWeather.wind.direction.value,
                feelsLike: weather.currentWeather.apparentTemperature.converted(to: UnitTemperature.celsius).value,
                visibility: weather.currentWeather.visibility.value,
                precipitation: precipitation,
                pressure: weather.currentWeather.pressure.value,
                uvIndex: weather.currentWeather.uvIndex.value,
                sunrise: sunriseStr,
                sunset: sunsetStr
            )
            
            // Save to shared defaults
            saveWeatherToSharedDefaults(weather: sharedWeather)
            
            // Reload all widget timelines
            WidgetCenter.shared.reloadAllTimelines()
            
        } catch {
            print("WidgetLocationManager weather fetch error: \(error.localizedDescription)")
        }
    }
    
    private func fetchCityName(for location: CLLocation) async -> String {
        do {
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
            if let city = placemarks.first?.locality {
                return city
            }
        } catch {
            print("Geocoding error: \(error.localizedDescription)")
        }
        return "Unknown"
    }
    
    private func saveWeatherToSharedDefaults(weather: SharedWeather) {
        if let data = try? JSONEncoder().encode(weather),
           let sharedDefaults = UserDefaults(suiteName: appGroupID) {
            sharedDefaults.set(data, forKey: "currentWeather")
            sharedDefaults.synchronize()
        }
    }
}
