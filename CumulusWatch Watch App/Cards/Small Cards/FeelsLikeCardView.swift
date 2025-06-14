//
//  FeelsLikeCardView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 13/06/2025.
//


import SwiftUI


struct FeelsLikeCardView: View {
    let feelsLike: Double
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Feels Like")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Image(systemName: "thermometer")
                .font(.title)
                .foregroundColor(.white)
            
            Text(formatTemperature(feelsLike))
                .font(.callout)
                .foregroundColor(.white)
        }
        .smallGlassCard()
    }
}
