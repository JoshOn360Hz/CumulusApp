import SwiftUI
import WidgetKit

struct WidgetSettingsView: View {
    @AppStorage("widgetRefreshInterval", store: UserDefaults(suiteName: "group.com.josh.cumulus")) private var widgetRefreshInterval: Int = 30
    var accentColor: Color
    
    let refreshOptions: [(label: String, minutes: Int)] = [
        ("15 minutes", 15),
        ("30 minutes", 30),
        ("1 hour", 60),
        ("Off", 0)
    ]
    
    var body: some View {
        Section("Widget") {
            Picker("Refresh Interval", selection: $widgetRefreshInterval) {
                ForEach(refreshOptions, id: \.minutes) { option in
                    Text(option.label).tag(option.minutes)
                }
            }
            .tint(accentColor)
            .onChange(of: widgetRefreshInterval) { oldValue, newValue in
                NotificationCenter.default.post(
                    name: NSNotification.Name("WidgetRefreshIntervalChanged"),
                    object: nil,
                    userInfo: ["interval": newValue]
                )
                WidgetCenter.shared.reloadTimelines(ofKind: "WeatherWidget")
            }
            
        }
    }
}
