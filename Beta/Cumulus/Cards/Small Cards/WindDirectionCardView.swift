//
//  WindDirectionCardView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 12/06/2025.
//


import SwiftUI
import WeatherKit
import CoreLocation


import SwiftUI
import WeatherKit

// Converts a wind bearing (in degrees) to a cardinal direction label.

private func cardinalDirection(from degrees: Double) -> String {
    let directions = ["North", "North East", "East", "South East", "South", "South West", "West", "North West"]
    let index = Int((degrees + 22.5) / 45.0) % 8
    return directions[index]
}

struct WindDirectionCardView: View {
    //  Degrees from `weather.currentWeather.wind.direction`
    let directionDegrees: Double
    // Speed from `weather.currentWeather.wind.speed` (not displayed now)
    let speed: Measurement<UnitSpeed>
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Wind Dir.")
                .font(.headline)
                .foregroundColor(.white)
            
            // Rotate an arrow or compass icon by the wind bearing
            Image(systemName: "location.north.fill")
                .font(.title)
                .foregroundColor(.white)
                .rotationEffect(.degrees(directionDegrees))
            
            let directionLabel = cardinalDirection(from: directionDegrees)
            Text(directionLabel)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: 165, height: 120)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}
