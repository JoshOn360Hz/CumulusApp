//
//  DayForecastCardView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 12/06/2025.
//
import SwiftUI

struct ForecastDayView: View {
    let forecast: ForecastDay

    var body: some View {
        VStack(spacing: 8) {
            Text(forecast.day)
                .font(.headline)
                .foregroundColor(.white)

            Image(systemName: forecast.iconName)
                .font(.title)
                .foregroundColor(.white)

            Text(formatCardTemperature(forecast.highTemperature))
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .clipShape(Capsule())
    }
}
