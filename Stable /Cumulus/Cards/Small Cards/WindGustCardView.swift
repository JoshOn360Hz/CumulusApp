import SwiftUI
import WeatherKit

struct WindGustCardView: View {
    let gust: Measurement<UnitSpeed>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "wind")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                Text("WIND GUST")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(0.5)
            }
            .padding(.top, 14)
            .padding(.horizontal, 14)

            Spacer()

            Text(formatWindSpeed(gust))
                .font(.system(size: 28, weight: .thin, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 14)

            Text("Max gusts")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
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
