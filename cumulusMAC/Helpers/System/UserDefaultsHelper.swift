import SwiftUI
import CoreLocation

class UserDefaultsHelper {
    private static let recentSearchesKey = "RecentSearches"
    private static let sharedDefaults = UserDefaults(suiteName: "group.com.josh.cumulus")
    
    /// Load recent city searches from UserDefaults
    static func loadRecentCities() -> [String] {
        let savedCities = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
        return savedCities
    }
    
    /// Save an array of recent cities to UserDefaults
    static func saveRecentCities(_ cities: [String]) {
        UserDefaults.standard.set(cities, forKey: recentSearchesKey)
    }
    
    /// Inserts a new city at the front of recentCities, removing duplicates & limiting to a specified number
    static func insertCityAsFirst(_ city: String, into recentCities: [String], limit: Int = 6) -> [String] {
        // Skip if "Unknown"
        guard city.lowercased() != "unknown" else { return recentCities }
        
        var cities = recentCities.filter { $0.lowercased() != city.lowercased() }
        cities.insert(city, at: 0)
        if cities.count > limit {
            cities = Array(cities.prefix(limit))
        }
        
        saveRecentCities(cities)
        return cities
    }
    
    /// Saves user location to the shared container, used by widget extension
    static func saveLastLocation(_ location: CLLocation) {
        let coords = ["lat": location.coordinate.latitude, "lon": location.coordinate.longitude]
        sharedDefaults?.set(coords, forKey: "LastLocation")
        sharedDefaults?.synchronize()
    }
}
