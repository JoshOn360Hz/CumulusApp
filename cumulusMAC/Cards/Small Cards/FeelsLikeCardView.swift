//
//  FeelsLikeCardView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 12/06/2025.
//


import SwiftUI
import WeatherKit
import CoreLocation


struct FeelsLikeCardView: View {
    /// Expected apparent temperature measurement
    let feelsLike: Measurement<UnitTemperature>
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Feels Like")
                .font(.headline)
                .foregroundColor(.white)
            Image(systemName: "thermometer")
                .font(.title)
                .foregroundColor(.white)
            let tempValue = feelsLike.value
            Text("\(tempValue, specifier: "%.0f")°")
                .font(.title2)
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