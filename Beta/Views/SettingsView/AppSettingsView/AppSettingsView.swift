import SwiftUI

struct AppSettingsView: View {
    @Binding var showResetConfirmation: Bool
    var accentColor: Color
    var resetAppSettings: () -> Void
    
    var body: some View {
        Section("App") {
            Link(destination: URL(string: "mailto:joshcumulus@proton.me?subject=Cumulus%20App%20Support")!) {
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(accentColor)
                        .frame(width: 25)
                    Text("Need Help?")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.red)
                        .frame(width: 25)
                    Text("Reset All Settings")
                }
            }
            .alert("Reset All Settings", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAppSettings()
                }
            } message: {
                Text("This will reset all app settings to their defaults and show the initial setup screen.")
            }
        }
    }
}
