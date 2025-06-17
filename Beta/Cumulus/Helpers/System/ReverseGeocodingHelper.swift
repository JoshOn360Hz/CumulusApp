//
//  ReverseGeocodingHelper.swift
//  Cumulus
//
//  Created by Josh Mansfield on 11/06/2025.
//

import CoreLocation

struct ReverseGeocodingResult {
    let cityName: String
    let timeZone: TimeZone?
}

struct ReverseGeocodingHelper {
    static func fetchCityDetails(for location: CLLocation) async -> ReverseGeocodingResult {
        do {
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                return ReverseGeocodingResult(cityName: "Unknown", timeZone: nil)
            }
            
            let city = placemark.locality ?? "Unknown"
            let isoCode = placemark.isoCountryCode ?? ""
            let name = isoCode.isEmpty ? city : "\(city), \(isoCode)"
            return ReverseGeocodingResult(cityName: name, timeZone: placemark.timeZone)
        } catch {
            print("Error reverse geocoding: \(error)")
            return ReverseGeocodingResult(cityName: "Unknown", timeZone: nil)
        }
    }
}
