import SwiftUI

struct SplashScreenView: View {
    // Use AppStorage to remember if the splash screen has been shown.
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    // Save the chosen temperature unit.
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "system"
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.mint]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
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
                        hasLaunchedBefore = true
                    } label: {
                        Text("Celsius")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(GlassButtonStyle())
                    
                    Button {
                        temperatureUnit = "fahrenheit"
                        hasLaunchedBefore = true
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

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
