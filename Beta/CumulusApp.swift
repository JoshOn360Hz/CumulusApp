import SwiftUI

@main
struct WeatherApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @AppStorage("colorScheme") private var colorScheme: String = "system"
    @State private var showWhatsNew = false
    @State private var showSplash = false

    init() {
        let firstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        let newVersion = AppVersionManager.isNewVersion()

        _showSplash = State(initialValue: firstLaunch)
        
        _showWhatsNew = State(initialValue: !firstLaunch && newVersion)
    }
    
    var preferredColorScheme: ColorScheme? {
        switch colorScheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil // system default
        }
    }

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView {
                    hasLaunchedBefore = true
                    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                    showSplash = false
                    
                    // Show what's new on first successful launch
                    if AppVersionManager.isNewVersion() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showWhatsNew = true
                        }
                    }
                }
                .preferredColorScheme(preferredColorScheme)
            } else {
                MainTabView(showSplash: $showSplash)
                    .preferredColorScheme(preferredColorScheme)
                    .sheet(isPresented: $showWhatsNew) {
                        WhatsNewSheet(showSheet: $showWhatsNew)
                    }
            }
        }
    }
}
