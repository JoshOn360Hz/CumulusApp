import SwiftUI

struct HourlyForecastCardView: View {
    let hourlyForecast: [HourlyForecast]
    let locationTimeZone: TimeZone?
    @AppStorage("accentColorName") private var accentColorName: String = "blue"
    @AppStorage("timeFormat") private var timeFormat: String = "12h"

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

    private var temps: [Double] { hourlyForecast.map { $0.temperature } }
    private var minTemp: Double { temps.min() ?? 0 }
    private var maxTemp: Double { temps.max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                Text("HOURLY FORECAST")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Temperature graph
                    tempGraph
                        .padding(.horizontal, 8)

                    // Hour items
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(Array(hourlyForecast.enumerated()), id: \.element.id) { idx, hour in
                            VStack(spacing: 6) {
                                Text(formattedHour(hour.time, in: locationTimeZone))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                Image(systemName: getWeatherIcon(for: hour.symbolName))
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)

                                if hour.precipitationChance > 0.1 {
                                    Text("\(Int(hour.precipitationChance * 100))%")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(accentColor)
                                } else {
                                    Text(" ")
                                        .font(.system(size: 11))
                                }
                            }
                            .frame(width: 56)
                            .padding(.bottom, 12)
                        }
                    }
                    .padding(.horizontal, 8)
                }
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

    private var tempGraph: some View {
        GeometryReader { geo in
            let width = CGFloat(hourlyForecast.count) * 56
            let height: CGFloat = 52
            let range = maxTemp - minTemp
            let effectiveRange = range < 1 ? 1 : range

            ZStack {
                // Filled gradient under curve
                Path { path in
                    guard !hourlyForecast.isEmpty else { return }
                    let points = graphPoints(width: width, height: height, range: effectiveRange)
                    path.move(to: CGPoint(x: points[0].x, y: height))
                    path.addLine(to: points[0])
                    for i in 1..<points.count {
                        let prev = points[i - 1]
                        let curr = points[i]
                        let midX = (prev.x + curr.x) / 2
                        path.addCurve(to: curr, control1: CGPoint(x: midX, y: prev.y), control2: CGPoint(x: midX, y: curr.y))
                    }
                    path.addLine(to: CGPoint(x: points.last!.x, y: height))
                    path.closeSubpath()
                }
                .fill(LinearGradient(
                    colors: [Color.white.opacity(0.2), Color.white.opacity(0.02)],
                    startPoint: .top, endPoint: .bottom
                ))

                // Curve line
                Path { path in
                    guard !hourlyForecast.isEmpty else { return }
                    let points = graphPoints(width: width, height: height, range: effectiveRange)
                    path.move(to: points[0])
                    for i in 1..<points.count {
                        let prev = points[i - 1]
                        let curr = points[i]
                        let midX = (prev.x + curr.x) / 2
                        path.addCurve(to: curr, control1: CGPoint(x: midX, y: prev.y), control2: CGPoint(x: midX, y: curr.y))
                    }
                }
                .stroke(Color.white.opacity(0.6), lineWidth: 1.5)

                // Temperature labels on curve
                ForEach(Array(hourlyForecast.enumerated()), id: \.element.id) { idx, hour in
                    let points = graphPoints(width: width, height: height, range: effectiveRange)
                    if idx < points.count {
                        Text(formatCardTemperature(hour.temperature))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .position(x: points[idx].x, y: max(points[idx].y - 10, 4))
                    }
                }
            }
            .frame(width: width, height: height)
        }
        .frame(height: 52)
        .frame(width: CGFloat(hourlyForecast.count) * 56)
    }

    private func graphPoints(width: CGFloat, height: CGFloat, range: Double) -> [CGPoint] {
        hourlyForecast.enumerated().map { idx, hour in
            let x = CGFloat(idx) * 56 + 28
            let normalized = CGFloat((hour.temperature - minTemp) / range)
            let y = height - normalized * (height - 16) - 4
            return CGPoint(x: x, y: y)
        }
    }

    private func formattedHour(_ date: Date, in timeZone: TimeZone?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = timeFormat == "24h" ? "HH:mm" : "ha"
        formatter.timeZone = timeZone ?? .current
        return formatter.string(from: date)
    }
}
