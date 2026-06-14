import SwiftUI
import WeatherKit
import CoreLocation

struct UVIndexCardView: View {
    let uvIndex: Int
    @AppStorage("accentColorName") private var accentColorName: String = "blue"

    private var accentColor: Color {
        switch accentColorName {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "purple": return .purple
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        case "mint": return .mint
        default: return .blue
        }
    }

    private var uvLabel: String {
        switch uvIndex {
        case 0...2: return "Low"
        case 3...5: return "Moderate"
        case 6...7: return "High"
        case 8...10: return "Very High"
        default: return "Extreme"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                Text("UV INDEX")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(0.5)
            }
            .padding(.top, 14)
            .padding(.horizontal, 14)

            Spacer()

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("\(uvIndex)")
                    .font(.system(size: 36, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                Text(uvLabel)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(accentColor)
            }
            .padding(.horizontal, 14)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.15)).frame(height: 5)
                    Capsule()
                        .fill(accentColor)
                        .frame(width: geo.size.width * CGFloat(min(uvIndex, 11)) / 11.0, height: 5)
                }
            }
            .frame(height: 5)
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
