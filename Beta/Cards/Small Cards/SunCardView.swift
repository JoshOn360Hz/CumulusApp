import SwiftUI
import WeatherKit
import CoreLocation

struct SunCardView: View {
    let title: String
    let time: Date
    let systemImageName: String
    let timeZone: TimeZone?
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Image(systemName: systemImageName)
                .font(.title)
                .foregroundColor(.white)
            Text(formatTime(time, in: timeZone))
                .font(.title2)
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: 160, height: 120)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
    
    private func formatTime(_ date: Date, in timeZone: TimeZone?) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = timeZone ?? .current
        return formatter.string(from: date)
    }
}


struct SunTimesCardsView: View {
    let sunrise: Date
    let sunset: Date
    let timeZone: TimeZone?
    
    var body: some View {
        HStack(spacing: 20) {
            SunCardView(title: "Sunrise", time: sunrise, systemImageName: "sunrise.fill", timeZone: timeZone)
            SunCardView(title: "Sunset", time: sunset, systemImageName: "sunset.fill", timeZone: timeZone)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}
    private func formatTime(_ date: Date, in timeZone: TimeZone?) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = timeZone ?? .current
        return formatter.string(from: date)
    }


