//
//  SharedWeather.swift
//  Cumulus
//
//  Created by Josh Mansfield on 29/05/2025.
//

import Foundation

struct SharedWeather: Codable {
    let temperature: Double
    let condition: String
    let symbolName: String
    let isDaytime: Bool
    let location: String
}

