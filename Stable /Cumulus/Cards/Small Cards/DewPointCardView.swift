import SwiftUI
import WeatherKit

struct DewPointCardView: View {
    let dewPoint: Measurement<UnitTemperature>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "thermometer.and.liquid.waves")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                Text("DEW POINT")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(0.5)
            }
            .padding(.top, 14)
            .padding(.horizontal, 14)

            Spacer()

            Text(formatCardTemperature(dewPoint.converted(to: .celsius).value))
                .font(.system(size: 36, weight: .thin, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 14)

            Text(dewPointDescription(dewPoint.converted(to: .celsius).value))
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
    }

    private func dewPointDescription(_ celsius: Double) -> String {
        switch celsius {
        case ..<10: return "Dry"
        case 10..<16: return "Comfortable"
        case 16..<21: return "Humid"
        default: return "Very Humid"
        }
    }
}
