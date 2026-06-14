import SwiftUI
import WeatherKit
import CoreLocation

private func cardinalDirection(from degrees: Double) -> String {
    let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    let index = Int((degrees + 22.5) / 45.0) % 8
    return directions[index]
}

struct WindDirectionCardView: View {
    let directionDegrees: Double
    let speed: Measurement<UnitSpeed>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "wind")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                Text("WIND")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(0.5)
            }
            .padding(.top, 14)
            .padding(.horizontal, 14)

            Spacer()

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                        .frame(width: 44, height: 44)
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(directionDegrees))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(formatWindSpeed(speed))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    Text(cardinalDirection(from: directionDegrees))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .cardBackground()
        .cornerRadius(25)
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white.opacity(0.25), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .refreshOnWindSpeedUnitChange()
    }
}
