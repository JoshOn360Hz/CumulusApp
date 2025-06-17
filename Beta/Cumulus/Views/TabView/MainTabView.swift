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
        TabView(selection: $appStateManager.selectedTabIndex) {
            WeatherTabView(showSplash: $showSplash)
                .environmentObject(appStateManager)
                .accentColor(.primary)
                .tabItem {
                    Image(systemName: "cloud.sun.fill")
                    Text("Weather")
                }
                .tag(0)
            
            SearchTabView()
                .environmentObject(appStateManager)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
            
            SettingsTabView(showSplash: $showSplash)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(accentColor)
        .preferredColorScheme(preferredColorScheme)
        .tabViewStyle(.tabBarOnly)
        .onChange(of: appStateManager.selectedTabIndex) { oldValue, newValue in
            
        }
    }
}
