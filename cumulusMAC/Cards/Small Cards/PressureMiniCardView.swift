//
//  PressureMiniCardView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 12/06/2025.
//


import SwiftUI
import WeatherKit
import CoreLocation

struct PressureMiniCardView: View {
    let pressure: Measurement<UnitPressure>
    
    // Define a rough atmospheric pressure range in hPa
    let minPressure: Double = 950
    let maxPressure: Double = 1050
    
    private var pressureValue: Double {
        /// Convert to hPa for display and bar calculation
        pressure.converted(to: .hectopascals).value
    }
    
    /// Calculate fraction (0...1) within the normal pressure range
    private var pressurePercentage: Double {
        let clamped = max(min(pressureValue, maxPressure), minPressure)
        return (clamped - minPressure) / (maxPressure - minPressure)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Pressure")
                .font(.headline)
                .foregroundColor(.white)
            
            /// Icon
            Image(systemName: "barometer")
                .font(.title)
                .foregroundColor(.white)
            
            /// Display numeric value
            Text("\(pressureValue, specifier: "%.0f") hPa")
                .font(.subheadline)
                .foregroundColor(.white)
            
            /// Small horizontal bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                    Capsule()
                        .fill(Color.white)
                        .frame(width: geo.size.width * CGFloat(pressurePercentage))
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 8)
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
