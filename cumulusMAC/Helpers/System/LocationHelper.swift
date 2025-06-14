import SwiftUI
import CoreLocation
import WeatherKit

class LocationHelper {
    /// Fetches the city name (and ISO code) for a given location
    static func fetchCityName(for location: CLLocation) async -> (cityName: String, timeZone: TimeZone?) {
        do {
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let city = placemark.locality ?? "Unknown"
                let isoCode = placemark.isoCountryCode ?? ""
                
                let cityName: String
                if !isoCode.isEmpty {
                    cityName = "\(city), \(isoCode)"
                } else {
                    cityName = city
                }
                
                return (cityName, placemark.timeZone)
            } else {
                return ("Unknown", nil)
            }
        } catch {
            print("Error reverse geocoding: \(error)")
            return ("Unknown", nil)
        }
    }
    
    /// Geocode a city string into a CLLocation
    static func geocodeCity(_ city: String) async throws -> CLLocation {
        let placemarks = try await CLGeocoder().geocodeAddressString(city)
        guard let first = placemarks.first, let location = first.location else {
            throw NSError(domain: "NoLocation", code: 404, userInfo: nil)
        }
        return location
    }
}
