import SwiftUI
import WidgetKit


struct SettingsTabView: View {
    @Binding var showSplash: Bool
    @AppStorage("accentColorName") private var accentColorName: String = "blue"
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "system"
    @AppStorage("windSpeedUnit") private var windSpeedUnit: String = "kmh"
    @AppStorage("colorScheme") private var colorScheme: String = "system"
    @State private var currentIcon: String? = nil
    @State private var showResetConfirmation = false
    @State private var showCardReorderView = false
    @State private var showWhatsNew = false
    @State private var showWidgetRefreshAlert = false
    @State private var showWatchSettings = false
    
    var preferredColorScheme: ColorScheme? {
        switch colorScheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil 
        }
    }
    
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
    
    let accentColorOptions: [(name: String, color: Color)] = [
        ("Blue", .blue),
        ("Red", .red),
        ("Orange", .orange),
        ("Yellow", .yellow),
        ("Green", .green),
        ("Purple", .purple),
        ("Pink", .pink),
        ("Teal", .teal),
        ("Indigo", .indigo),
        ("Mint", .mint)
    ]
    
    let iconOptions: [(name: String, filename: String?)] = [
        ("Default", nil), ("Blue", "icon-blue"), ("Dark", "icon-dark"),
        ("Bubblegum", "icon-purple"), ("Red", "icon-red"), ("Teal", "icon-teal"),
        ("Green", "icon-green"), ("Purple", "icon-purp"), ("Pink", "icon-pink"),
        ("Bear", "icon-bear"), ("Cat", "icon-cat"), ("Dog", "icon-dog"),
        ("Fox", "icon-fox"), ("Penguin", "icon-penguin"), ("Shark", "icon-shark")
    ]
    
    var body: some View {
        NavigationView {
            List {
                    AppearanceSettingsView(
                    accentColorName: $accentColorName, 
                    colorScheme: $colorScheme, 
                    currentIcon: $currentIcon, 
                    accentColorOptions: accentColorOptions,
                    accentColor: accentColor
                )
                
                LayoutSettingsView(
                    showCardReorderView: $showCardReorderView, 
                    showWatchSettings: $showWatchSettings, 
                    accentColor: accentColor
                )
                
                UnitSettingsView(
                    temperatureUnit: $temperatureUnit, 
                    windSpeedUnit: $windSpeedUnit
                )
                
                AppSettingsView(
                    showResetConfirmation: $showResetConfirmation, 
                    accentColor: accentColor, 
                    resetAppSettings: resetAppSettings
                )
                
                AboutSettingsView(
                    showWhatsNew: $showWhatsNew, 
                    accentColor: accentColor
                )
                
                #if DEBUG
                DeveloperSettingsView(
                    showSplash: $showSplash, 
                    showWhatsNew: $showWhatsNew, 
                    showResetConfirmation: $showResetConfirmation, 
                    showWidgetRefreshAlert: $showWidgetRefreshAlert,
                    resetAppSettings: resetAppSettings,
                    refreshWidgets: refreshWidgets
                )
                #endif
            }
            .navigationTitle("Settings")
            .preferredColorScheme(preferredColorScheme)
            .sheet(isPresented: $showCardReorderView) {
                CardReorderView()
            }
            .sheet(isPresented: $showWatchSettings) {
                WatchSettingsView()
            }
            .fullScreenCover(isPresented: $showWhatsNew) {
                WhatsNewSheet(showSheet: $showWhatsNew)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func resetAppSettings() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        accentColorName = "blue"
        temperatureUnit = "system"
        windSpeedUnit = "kmh"
        colorScheme = "system"
        currentIcon = nil
        UserDefaults.standard.set(false, forKey: "hasLaunchedBefore")
        showSplash = true
    }
    
    func refreshWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
        
#if canImport(UIKit)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
#endif
        
        print("Widgets refreshed manually")
        
        showWidgetRefreshAlert = true
    }
    
}

