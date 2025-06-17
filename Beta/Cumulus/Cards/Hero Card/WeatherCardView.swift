import SwiftUI
import WeatherKit

struct WeatherCardView: View {
    let weather: Weather
    let cityName: String
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "system"
    @AppStorage("windSpeedUnit") private var windSpeedUnit: String = "kmh"

    var body: some View {
        VStack(spacing: 15) {
            // City Name
            Text(cityName.components(separatedBy: ",").first ?? cityName)
                .font(.title)
                .foregroundColor(.white)

            // Weather Symbol
            Image(systemName: weather.currentWeather.symbolName)
                .font(.system(size: 60))
                .foregroundColor(.white)

            // Temperature
            Text(formatCardTemperature(weather.currentWeather.temperature.converted(to: .celsius).value))
                .font(.system(size: 50))
                .foregroundColor(.white)

            // Weather Condition Description
            Text(weather.currentWeather.condition.description)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))

            // Wind & Humidity Info
            HStack(spacing: 40) {
                VStack {
                    Text("Wind")
                        .foregroundColor(.white.opacity(0.7))

                    Text(formatWindSpeed(weather.currentWeather.wind.speed))
                        .foregroundColor(.white)
                }
                VStack {
                    Text("Humidity")
                        .foregroundColor(.white.opacity(0.7))

                    let humidityPercent = weather.currentWeather.humidity * 100
                    Text("\(humidityPercent, specifier: "%.0f")%")
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 5)
        }
        .frame(width: 350, height: 400)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .refreshOnUnitsChange() 
    }
}
