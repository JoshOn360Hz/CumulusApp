import SwiftUI
import WeatherKit
import CoreLocation

struct SunTimesCardsView: View {
    let sunrise: Date
    let sunset: Date
    let timeZone: TimeZone?
    @AppStorage("timeFormat") private var timeFormat: String = "12h"

    private var progress: CGFloat {
        let now = Date()
        let total = sunset.timeIntervalSince(sunrise)
        let elapsed = now.timeIntervalSince(sunrise)
        return CGFloat(max(0, min(1, elapsed / total)))
    }

    private var dayLengthString: String {
        let seconds = sunset.timeIntervalSince(sunrise)
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        return "\(h)h \(m)m"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack(spacing: 4) {
                Image(systemName: "sun.horizon.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                Text("SUN")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(0.5)
                Spacer()
                Text(dayLengthString)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.top, 14)
            .padding(.horizontal, 16)

            // Arc
            SunArcView(sunrise: sunrise, sunset: sunset)
                .frame(height: 100)
                .padding(.horizontal, 12)
                .padding(.top, 8)

            // Sunrise / Sunset row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Image(systemName: "sunrise.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange.opacity(0.8))
                        Text("Sunrise")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    Text(formatTime(sunrise, in: timeZone))
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }

                Spacer()

                // Day progress indicator
                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    Text("of daylight")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.35))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    HStack(spacing: 4) {
                        Text("Sunset")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.55))
                        Image(systemName: "sunset.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange.opacity(0.6))
                    }
                    Text(formatTime(sunset, in: timeZone))
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .cardBackground()
        .cornerRadius(25)
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white.opacity(0.25), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    private func formatTime(_ date: Date, in timeZone: TimeZone?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = timeFormat == "24h" ? "HH:mm" : "h:mm a"
        formatter.timeZone = timeZone ?? .current
        return formatter.string(from: date)
    }
}

struct SunArcView: View {
    let sunrise: Date
    let sunset: Date

    private var progress: CGFloat {
        let now = Date()
        let total = sunset.timeIntervalSince(sunrise)
        let elapsed = now.timeIntervalSince(sunrise)
        return CGFloat(max(0, min(1, elapsed / total)))
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cx = w / 2
            let peakY: CGFloat = 10

            let cy = (cx*cx + h*h - peakY*peakY) / (2*(h - peakY))
            let r = cy - peakY

            let leftAngle  = atan2(Double(h - cy), Double(-cx))
            let rightAngle = atan2(Double(h - cy), Double(cx))
            let progressAngle = leftAngle + (rightAngle - leftAngle) * Double(progress)

            let sunX = cx + CGFloat(cos(progressAngle)) * r
            let sunY = cy + CGFloat(sin(progressAngle)) * r

            ZStack {
                // Horizon line
                Path { path in
                    path.move(to: CGPoint(x: 0, y: h))
                    path.addLine(to: CGPoint(x: w, y: h))
                }
                .stroke(Color.white.opacity(0.1), lineWidth: 1)

                // Track arc
                Path { path in
                    path.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                                startAngle: .radians(leftAngle),
                                endAngle: .radians(rightAngle),
                                clockwise: true)
                }
                .stroke(Color.white.opacity(0.12), lineWidth: 2)

                // Filled area under progress arc
                Path { path in
                    path.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                                startAngle: .radians(leftAngle),
                                endAngle: .radians(progressAngle),
                                clockwise: true)
                    path.addLine(to: CGPoint(x: cx + CGFloat(cos(leftAngle)) * r,
                                            y: cy + CGFloat(sin(leftAngle)) * r))
                }
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.18), Color.yellow.opacity(0.06)],
                        startPoint: .top, endPoint: .bottom
                    )
                )

                // Progress arc
                Path { path in
                    path.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                                startAngle: .radians(leftAngle),
                                endAngle: .radians(progressAngle),
                                clockwise: true)
                }
                .stroke(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.9), Color.yellow],
                        startPoint: .leading, endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )

                // Glow behind sun dot
                Circle()
                    .fill(Color.yellow.opacity(0.25))
                    .frame(width: 22, height: 22)
                    .position(x: sunX, y: sunY)

                // Sun dot
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white, Color.yellow],
                            center: .center,
                            startRadius: 0,
                            endRadius: 6
                        )
                    )
                    .frame(width: 12, height: 12)
                    .shadow(color: Color.yellow.opacity(0.9), radius: 6)
                    .position(x: sunX, y: sunY)

                // Endpoint dots
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 5, height: 5)
                    .position(x: cx + CGFloat(cos(leftAngle)) * r,
                              y: cy + CGFloat(sin(leftAngle)) * r)

                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 5, height: 5)
                    .position(x: cx + CGFloat(cos(rightAngle)) * r,
                              y: cy + CGFloat(sin(rightAngle)) * r)
            }
        }
        .clipShape(Rectangle())
    }
}
