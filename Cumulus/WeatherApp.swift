import SwiftUI

@main
struct WeatherApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasLaunchedBefore {
                WeatherView()
            } else {
                SplashScreenView()
            }
        }
    }
}
