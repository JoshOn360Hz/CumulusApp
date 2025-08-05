import SwiftUI

struct UnitSettingsView: View {
    @Binding var temperatureUnit: String
    @Binding var windSpeedUnit: String
    
    var body: some View {
        Section("Units") {
            Picker("Temperature", selection: $temperatureUnit) {
                Text("System Default").tag("system")
                Text("Celsius (°C)").tag("celsius")
                Text("Fahrenheit (°F)").tag("fahrenheit")
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: temperatureUnit) { oldValue, newValue in
                WatchConnectivityManager.shared.sendUnitsToWatch()
            }
            
            Picker("Wind Speed", selection: $windSpeedUnit) {
                Text("km/h").tag("kmh")
                Text("mph").tag("mph")
                Text("m/s").tag("ms")
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: windSpeedUnit) { oldValue, newValue in
                WatchConnectivityManager.shared.sendUnitsToWatch()
            }
        }
    }
}
