import SwiftUI

struct LayoutSettingsView: View {
    @Binding var showCardReorderView: Bool
    @Binding var showWatchSettings: Bool
    @StateObject private var watchManager = WatchConnectivityManager.shared
    var accentColor: Color
    
    var body: some View {
        Section("Layout") {
            Button(action: {
                showCardReorderView = true
            }) {
                HStack {
                    Image(systemName: "square.grid.3x3")
                        .foregroundColor(accentColor)
                        .frame(width: 25)
                    Text("Customize Cards")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                if watchManager.isWatchPaired {
                    showWatchSettings = true
                }
            }) {
                HStack {
                    Image(systemName: watchManager.isWatchPaired ? "applewatch" : "applewatch.slash")
                        .foregroundColor(watchManager.isWatchPaired ? accentColor : .secondary)
                        .frame(width: 25)
                    
                    Text(watchManager.isWatchPaired ? "Watch Settings" : "No Apple Watch paired")
                        .foregroundColor(watchManager.isWatchPaired ? .primary : .secondary)
                    
                    Spacer()
                    
                    if watchManager.isWatchPaired {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!watchManager.isWatchPaired)
        }
    }
}
