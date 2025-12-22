import SwiftUI

struct ForecastCardView: View {
    let forecastDays: [ForecastDay]
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            ForEach(forecastDays) { day in
                VStack(spacing: 0) {
                    Text(day.day)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 24, alignment: .bottom)
                    
                    Spacer(minLength: 8)
                    
                    Image(systemName: day.iconName)
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(height: 32, alignment: .center)
                    
                    Spacer(minLength: 8)
                    
                    Text(formatCardTemperature(day.highTemperature))
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(height: 24, alignment: .top)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(width: 315)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}
