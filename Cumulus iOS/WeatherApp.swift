import SwiftUI

@main
struct WeatherApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var showWhatsNew = false
    @State private var showSplash = false

    init() {
        // Set flags based on app state
        let firstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        let newVersion = AppVersionManager.isNewVersion()

        _showSplash = State(initialValue: firstLaunch)
        _showWhatsNew = State(initialValue: !firstLaunch && newVersion)
    }

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        hasLaunchedBefore = true
                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSplash = false
                        }
                    }
            } else {
                WeatherView()
                    .sheet(isPresented: $showWhatsNew) {
                        WhatsNewSheet(showSheet: $showWhatsNew)
                    }
            }
        }
    }
}
