import SwiftUI
import WeatherKit

struct MoonPhaseCardView: View {
    let moonPhase: MoonPhase?

    private var phaseName: String {
        guard let phase = moonPhase else { return "—" }
        switch phase {
        case .new: return "New Moon"
        case .waxingCrescent: return "Wax. Crescent"
        case .firstQuarter: return "First Quarter"
        case .waxingGibbous: return "Wax. Gibbous"
        case .full: return "Full Moon"
        case .waningGibbous: return "Wan. Gibbous"
        case .lastQuarter: return "Last Quarter"
        case .waningCrescent: return "Wan. Crescent"
        @unknown default: return "—"
        }
    }

    private var phaseSymbol: String {
        guard let phase = moonPhase else { return "moon" }
        switch phase {
        case .new: return "moonphase.new.moon"
        case .waxingCrescent: return "moonphase.waxing.crescent"
        case .firstQuarter: return "moonphase.first.quarter"
        case .waxingGibbous: return "moonphase.waxing.gibbous"
        case .full: return "moonphase.full.moon"
        case .waningGibbous: return "moonphase.waning.gibbous"
        case .lastQuarter: return "moonphase.last.quarter"
        case .waningCrescent: return "moonphase.waning.crescent"
        @unknown default: return "moon"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "moon.stars")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                Text("MOON PHASE")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(0.5)
            }
            .padding(.top, 14)
            .padding(.horizontal, 14)

            Spacer()

            HStack(spacing: 10) {
                Image(systemName: phaseSymbol)
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 32))
                    .foregroundStyle(.white)

                Text(phaseName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
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
