//
//  HourlyForecastCardView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 12/06/2025.
//


import SwiftUI

// MARK: - Hourly Forecast Card
struct HourlyForecastCardView: View {
    let hourlyForecast: [HourlyForecast]
    let locationTimeZone: TimeZone?

    var body: some View {
        VStack(spacing: 15) { // Set fixed spacing to match Daily Card
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) { // Ensures uniform horizontal spacing
                    ForEach(hourlyForecast) { hour in
                        VStack(spacing: 15) { // Matches spacing in Daily Forecast
                            Text(formattedHour(hour.time, in: locationTimeZone))
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Image(systemName: getWeatherIcon(for: hour.symbolName))
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                            
                            Text("\(Int(hour.temperature))°")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .frame(width: 60) // Ensures uniform width
                    }
                }
                .padding(.horizontal, 15) // Matches Daily Forecast padding
            }
        }
        .frame(width: 350, height: 160) // Matches Daily Forecast size
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
    
    private func formattedHour(_ date: Date, in timeZone: TimeZone?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        formatter.timeZone = timeZone ?? .current
        return formatter.string(from: date)
    }
}