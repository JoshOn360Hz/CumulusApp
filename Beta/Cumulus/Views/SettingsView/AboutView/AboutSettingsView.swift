import SwiftUI

struct AboutSettingsView: View {
    @Binding var showWhatsNew: Bool
    var accentColor: Color
    
    var body: some View {
        Section("About") {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(accentColor)
                    .frame(width: 25)
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                showWhatsNew = true
            }) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(accentColor)
                        .frame(width: 25)
                    Text("What's New")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Link(destination: URL(string: "https://weather-data.apple.com/legal-attribution.html")!) {
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(accentColor)
                        .frame(width: 25)
                    Text("Weather Data Attribution")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Link(destination: URL(string: "https://getcumulus.app")!) {
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(accentColor)
                        .frame(width: 25)
                    Text("Cumulus website")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
