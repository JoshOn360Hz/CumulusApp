//
//  AppleWeatherAttributionView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 12/06/2025.
//
import SwiftUI

struct AppleWeatherAttributionView: View {
    var condition: String
    var textColor: Color {
        condition.lowercased().contains("cloud") ? .black : .white
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Weather data provided by Weather")
                .font(.caption)
                .foregroundColor(textColor.opacity(0.8))
            Link(" Tap to view legal info ", destination: URL(string: "https://weather-data.apple.com/legal-attribution.html")!)
                .font(.caption)
                .foregroundColor(textColor)
        }
    }
}
