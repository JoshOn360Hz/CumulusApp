import SwiftUI

extension Color {
    static func weatherColor(for condition: String?) -> Color {
        if let condition = condition?.lowercased(), condition.contains("cloud") {
            return .black
        }
        return .white
    }
}

struct HourlyForecastCardView: View {
    let hourlyForecast: [HourlyForecast]
    let locationTimeZone: TimeZone?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(hourlyForecast) { hour in
                    VStack(spacing: 8) {
                        Text(formattedHour(hour.time, in: locationTimeZone))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)

                        Image(systemName: getWeatherIcon(for: hour.symbolName))
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)

                        Text(formatCardTemperature(hour.temperature))
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 10)
                    .frame(width: 60)
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(width: 345, height: 160)
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
