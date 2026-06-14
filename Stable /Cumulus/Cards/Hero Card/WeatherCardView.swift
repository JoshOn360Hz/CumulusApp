import SwiftUI
import WeatherKit

struct WeatherCardView: View {
    let weather: Weather
    let cityName: String
    var highTemp: Double? = nil
    var lowTemp: Double? = nil
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "system"
    @AppStorage("windSpeedUnit") private var windSpeedUnit: String = "kmh"
    @State private var iconScale: CGFloat = 1.0
    @State private var iconOpacity: Double = 1.0

    private var high: Double? { highTemp }
    private var low: Double? { lowTemp }

    var body: some View {
        VStack(spacing: 0) {
            // City name
            Text(cityName.components(separatedBy: ",").first ?? cityName)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 24)

            // Animated weather icon
            Image(systemName: weather.currentWeather.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 72))
                .foregroundStyle(.white)
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .padding(.top, 8)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                        iconScale = 1.06
                        iconOpacity = 0.85
                    }
                }

            // Temperature
            Text(formatCardTemperature(weather.currentWeather.temperature.converted(to: .celsius).value))
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 4)

            // Condition
            Text(weather.currentWeather.condition.description)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white.opacity(0.75))
                .padding(.top, 2)

            // H/L row
            if let h = high, let l = low {
                HStack(spacing: 4) {
                    Text("H:\(formatCardTemperature(h))")
                    Text("·").opacity(0.5)
                    Text("L:\(formatCardTemperature(l))")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 2)
            }

            Divider()
                .background(Color.white.opacity(0.25))
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)

            // Stats row
            HStack(spacing: 0) {
                statItem(icon: "wind", value: formatWindSpeed(weather.currentWeather.wind.speed), label: "Wind")
                Divider().frame(height: 36).background(Color.white.opacity(0.25))
                statItem(icon: "humidity", value: "\(Int(weather.currentWeather.humidity * 100))%", label: "Humidity")
                Divider().frame(height: 36).background(Color.white.opacity(0.25))
                statItem(icon: "thermometer.medium", value: formatCardTemperature(weather.currentWeather.apparentTemperature.converted(to: .celsius).value), label: "Feels Like")
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .cardBackground()
        .cornerRadius(28)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 16, x: 0, y: 6)
        .refreshOnUnitsChange()
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
    }
}
