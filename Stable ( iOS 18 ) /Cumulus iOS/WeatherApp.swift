import SwiftUI

@main
struct WeatherApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var showWhatsNew = false
    @State private var showSplash = false

    init() {
        let firstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        let newVersion = AppVersionManager.isNewVersion()

        _showSplash = State(initialValue: firstLaunch)
        _showWhatsNew = State(initialValue: !firstLaunch && newVersion)
    }

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView {
                    hasLaunchedBefore = true
                    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                    showSplash = false
                }
            } else {
                WeatherView(showSplash: $showSplash)
                    .sheet(isPresented: $showWhatsNew) {
                        WhatsNewSheet(showSheet: $showWhatsNew)
                    }
            }
        }
    }
}
