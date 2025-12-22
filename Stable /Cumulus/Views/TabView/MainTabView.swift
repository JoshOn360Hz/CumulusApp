import SwiftUI

struct MainTabView: View {
    @Binding var showSplash: Bool
    @AppStorage("accentColorName") private var accentColorName: String = "blue"
    @AppStorage("colorScheme") private var colorScheme: String = "system"
    @StateObject private var appStateManager = AppStateManager()
    
    var accentColor: Color {
        switch accentColorName {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        case "mint": return .mint
        default: return .blue
        }
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
    
    var body: some View {
        if #available(iOS 26.0, *) {
            TabView(selection: $appStateManager.selectedTab) {
                Tab("Weather", systemImage: "cloud.sun.fill", value: .weather) {
                    WeatherTabView(showSplash: $showSplash)
                        .environmentObject(appStateManager)
                        .accentColor(.primary)
                }
                
                Tab("Search", systemImage: "magnifyingglass", value: .search, role: .search) {
                    SearchTabView()
                        .environmentObject(appStateManager)
                }
                
                Tab("Settings", systemImage: "gearshape", value: .settings) {
                    SettingsTabView(showSplash: $showSplash)
                }
            }
            
            .accentColor(accentColor)
            .preferredColorScheme(preferredColorScheme)
            .tabViewStyle(.tabBarOnly)
            .onChange(of: appStateManager.selectedTab) { oldValue, newValue in }
            .tabBarMinimizeBehavior(.onScrollDown)
        } else {
            TabView(selection: $appStateManager.selectedTab) {
                Tab("Weather", systemImage: "cloud.sun.fill", value: .weather) {
                    WeatherTabView(showSplash: $showSplash)
                        .environmentObject(appStateManager)
                        .accentColor(.primary)
                }
                
                Tab("Search", systemImage: "magnifyingglass", value: .search, role: .search) {
                    SearchTabView()
                        .environmentObject(appStateManager)
                }
                
                Tab("Settings", systemImage: "gearshape", value: .settings) {
                    SettingsTabView(showSplash: $showSplash)
                }
            }
            
            .accentColor(accentColor)
            .preferredColorScheme(preferredColorScheme)
            .tabViewStyle(.tabBarOnly)
            .onChange(of: appStateManager.selectedTab) { oldValue, newValue in }
        }
    }
}


