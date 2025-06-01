import SwiftUI
import WeatherKit
import CoreLocation

// MARK: - Precipitation Card View
struct PrecipitationCardView: View {
    /// Expected daily precipitation measurement
    let dailyPrecipitation: Measurement<UnitLength>?
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Precipitation")
                .font(.headline)
                .foregroundColor(.white)
            Image(systemName: "drop.fill")
                .font(.title)
                .foregroundColor(.white)
            if let precip = dailyPrecipitation {
                // Convert to millimeters
                let mmValue = precip.converted(to: .millimeters).value
                Text("\(mmValue, specifier: "%.1f") mm")
                    .font(.title2)
                    .foregroundColor(.white)
            } else {
                Text("-- mm")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(width: 165, height: 120)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Feels Like Card View
struct FeelsLikeCardView: View {
    /// Expected apparent temperature measurement
    let feelsLike: Measurement<UnitTemperature>
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Feels Like")
                .font(.headline)
                .foregroundColor(.white)
            Image(systemName: "thermometer")
                .font(.title)
                .foregroundColor(.white)
            
            Text(formatCardTemperature(feelsLike.value))
                .font(.title2)
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: 165, height: 120)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}



// MARK: - UV Card View
struct UVIndexCardView: View {
    let uvIndex: Int
    var body: some View {
        VStack(spacing: 4) {
            Text("UV Index")
                .font(.headline)
                .foregroundColor(.white)
            Image(systemName: "sun.max")
                .font(.title)
                .foregroundColor(.white)
            Text("\(uvIndex)")
                .font(.title2)
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: 165, height: 120)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Visibility Card View
struct VisibilityCardView: View {
    let visibility: Measurement<UnitLength>?
    var body: some View {
        VStack(spacing: 4) {
            Text("Visibility")
                .font(.headline)
                .foregroundColor(.white)
            Image(systemName: "eye.fill")
                .font(.title)
                .foregroundColor(.white)
            if let vis = visibility {
                /// Convert to kilometers
                let kmValue = vis.converted(to: .kilometers).value
                Text("\(kmValue, specifier: "%.1f") km")
                    .font(.title2)
                    .foregroundColor(.white)
            } else {
                Text("--")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(width: 165, height: 120)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

//MARK: - Pressure view

struct PressureMiniCardView: View {
    let pressure: Measurement<UnitPressure>
    
    // Define a rough atmospheric pressure range in hPa
    let minPressure: Double = 950
    let maxPressure: Double = 1050
    
    private var pressureValue: Double {
        /// Convert to hPa for display and bar calculation
        pressure.converted(to: .hectopascals).value
    }
    
    /// Calculate fraction (0...1) within the normal pressure range
    private var pressurePercentage: Double {
        let clamped = max(min(pressureValue, maxPressure), minPressure)
        return (clamped - minPressure) / (maxPressure - minPressure)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Pressure")
                .font(.headline)
                .foregroundColor(.white)
            
            /// Icon
            Image(systemName: "barometer")
                .font(.title)
                .foregroundColor(.white)
            
            /// Display numeric value
            Text("\(pressureValue, specifier: "%.0f") hPa")
                .font(.subheadline)
                .foregroundColor(.white)
            
            /// Small horizontal bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                    Capsule()
                        .fill(Color.white)
                        .frame(width: geo.size.width * CGFloat(pressurePercentage))
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 8)
        }
        .padding()
        .frame(width: 165, height: 120)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}


//MARK: - Wind Direction Card

import SwiftUI
import WeatherKit

/// Converts a wind bearing (in degrees) to a cardinal direction label.
private func cardinalDirection(from degrees: Double) -> String {
    let directions = ["North", "North East", "East", "South East", "South", "South West", "West", "North West"]
    let index = Int((degrees + 22.5) / 45.0) % 8
    return directions[index]
}

struct WindDirectionCardView: View {
    /// Degrees from `weather.currentWeather.wind.direction`
    let directionDegrees: Double
    /// Speed from `weather.currentWeather.wind.speed` (not displayed now)
    let speed: Measurement<UnitSpeed>
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Wind Dir.")
                .font(.headline)
                .foregroundColor(.white)
            
            /// Rotate an arrow or compass icon by the wind bearing
            Image(systemName: "location.north.fill")
                .font(.title)
                .foregroundColor(.white)
                .rotationEffect(.degrees(directionDegrees))
            
            let directionLabel = cardinalDirection(from: directionDegrees)
            Text(directionLabel)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: 165, height: 120)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Sunrise / sunset cards

// MARK: - SunCardView
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

// MARK: - SunTimesCardsView
/// A container that shows two SunCardViews (for Sunrise and Sunset) side by side.
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


