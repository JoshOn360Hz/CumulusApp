//
//  MainWeatherCardView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 13/06/2025.
//


import SwiftUI

struct MainWeatherCardView: View {
    let weather: SharedWeather
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text(weather.location.components(separatedBy: ",").first ?? weather.location)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: getWeatherIcon(for: weather.symbolName))
                    .font(.title)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white)
                
                Text(formatTemperature(weather.temperature))
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Text(weather.condition)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 5)
        }
        .glassCard()
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
    }
}
