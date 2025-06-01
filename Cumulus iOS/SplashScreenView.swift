import SwiftUI

struct SplashScreenView: View {
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "system"
    var onFinish: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.black]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            Color.clear.background(.ultraThinMaterial).ignoresSafeArea()

            VStack(spacing: 30) {
                Image("applogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text("Welcome to Cumulus")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Please select a unit:")
                    .font(.title2)
                    .foregroundColor(.white)

                HStack(spacing: 20) {
                    Button {
                        temperatureUnit = "celsius"
                        onFinish()
                    } label: {
                        Text("Celsius")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(GlassButtonStyle())

                    Button {
                        temperatureUnit = "fahrenheit"
                        onFinish()
                    } label: {
                        Text("Fahrenheit")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(GlassButtonStyle())
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}
