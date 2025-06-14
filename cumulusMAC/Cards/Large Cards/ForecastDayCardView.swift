import SwiftUI

struct ForecastDayView: View {
    let forecast: ForecastDay

    var body: some View {
        VStack(spacing: 15) { // Matches spacing in Hourly Forecast
            Text(forecast.day)
                .font(.headline)
                .foregroundColor(.white)
            
            Image(systemName: forecast.iconName)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 40, height: 40) // Matches Hourly Forecast Image Size
            
            Text("\(forecast.highTemperature, specifier: "%.0f")°")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .frame(width: 350, height: 160) // Matches Hourly Forecast size
        .background(.ultraThinMaterial)
        .cornerRadius(25) // Same as Hourly Forecast
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}
