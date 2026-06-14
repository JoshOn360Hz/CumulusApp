import SwiftUI
import WeatherKit
import CoreLocation

struct VisibilityCardView: View {
    let visibility: Measurement<UnitLength>?

    private var kmValue: Double? { visibility?.converted(to: .kilometers).value }

    private var description: String {
        guard let km = kmValue else { return "" }
        switch km {
        case ..<1: return "Very Poor"
        case 1..<4: return "Poor"
        case 4..<10: return "Moderate"
        default: return "Good"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                Text("VISIBILITY")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(0.5)
            }
            .padding(.top, 14)
            .padding(.horizontal, 14)

            Spacer()

            if let km = kmValue {
                Text(km >= 10 ? "\(Int(km)) km" : String(format: "%.1f km", km))
                    .font(.system(size: 28, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
            } else {
                Text("—")
                    .font(.system(size: 28, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
            }

            Text(description)
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
}
