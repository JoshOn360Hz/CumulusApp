//
//  WindDirectionCardView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 13/06/2025.
//


import SwiftUI

struct WindDirectionCardView: View {
    let directionDegrees: Double
    let windSpeed: Double
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    
    private func cardinalDirection(from degrees: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((degrees + 22.5) / 45.0) % 8
        return directions[index]
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Wind")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .frame(width: 32, height: 32)
                
                Image(systemName: "location.north.fill")
                    .font(.caption)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(directionDegrees))
            }
            
            Text(formatWindSpeed(windSpeed))
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .smallGlassCard()
    }
}
