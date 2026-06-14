import SwiftUI

struct ForecastCardView: View {
    let forecastDays: [ForecastDay]
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

    private var allHighs: [Double] { forecastDays.map { $0.highTemperature } }
    private var allLows: [Double] { forecastDays.map { $0.lowTemperature } }
    private var globalMin: Double { allLows.min() ?? 0 }
    private var globalMax: Double { allHighs.max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                Text("\(forecastDays.count)-DAY FORECAST")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 4)

            ForEach(Array(forecastDays.enumerated()), id: \.element.id) { idx, day in
                forecastRow(day: day, isLast: idx == forecastDays.count - 1)
            }
        }
        .frame(maxWidth: .infinity)
        .cardBackground()
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    private func forecastRow(day: ForecastDay, isLast: Bool) -> some View {
        let range = globalMax - globalMin
        let effectiveRange = range < 1 ? 1 : range

        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Day label
                Text(isToday(day.date) ? "Today" : day.day)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 46, alignment: .leading)

                // Precip chance
                if day.precipitationChance > 0.1 {
                    HStack(spacing: 2) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 10))
                            .foregroundColor(accentColor)
                        Text("\(Int(day.precipitationChance * 100))%")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(accentColor)
                    }
                    .frame(width: 38)
                } else {
                    Spacer().frame(width: 38)
                }

                // Icon
                Image(systemName: day.iconName)
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 28)

                // Low temp
                Text(formatCardTemperature(day.lowTemperature))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
                    .frame(width: 36, alignment: .trailing)

                // Temperature range bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 6)

                        let lowFrac = CGFloat((day.lowTemperature - globalMin) / effectiveRange)
                        let highFrac = CGFloat((day.highTemperature - globalMin) / effectiveRange)
                        let barStart = lowFrac * geo.size.width
                        let barWidth = (highFrac - lowFrac) * geo.size.width

                        Capsule()
                            .fill(accentColor)
                            .frame(width: max(barWidth, 6), height: 6)
                            .offset(x: barStart)
                    }
                }
                .frame(height: 6)

                // High temp
                Text(formatCardTemperature(day.highTemperature))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            if !isLast {
                Divider()
                    .background(Color.white.opacity(0.12))
                    .padding(.horizontal, 16)
            }
        }
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }


}
