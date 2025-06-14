import SwiftUI
import WidgetKit

struct DeveloperSettingsView: View {
    @Binding var showSplash: Bool
    @Binding var showWhatsNew: Bool
    @Binding var showResetConfirmation: Bool
    @Binding var showWidgetRefreshAlert: Bool
    @StateObject private var watchManager = WatchConnectivityManager.shared
    
    var resetAppSettings: () -> Void
    var refreshWidgets: () -> Void
    
    var body: some View {
        Section("Developer") {
            HStack {
                Image(systemName: "hammer")
                    .foregroundColor(.red)
                    .frame(width: 25)
                Text("Development Version")
                    .foregroundColor(.red)
                Spacer()
                Text("3.0 Build 12")
                    .foregroundColor(.red)
            }
            
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.red)
                    .frame(width: 25)
                Text("Build Date:")
                    .foregroundColor(.red)
                Spacer()
                Text("13 Jul 25")
                    .foregroundColor(.red)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "applewatch.watchface")
                        .foregroundColor(.red)
                        .frame(width: 25)
                    Text("Emulate Watch Connection")
                        .foregroundColor(.red)
                }
                
                HStack(spacing: 8) {
                    ForEach(["No", "Connected", "Not Paired"], id: \.self) { option in
                        Button(action: {
                            watchManager.emulateWatchConnection = option
                        }) {
                            Text(option)
                                .font(.caption)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(watchManager.emulateWatchConnection == option ? Color.red : Color.red.opacity(0.2))
                                )
                                .foregroundColor(watchManager.emulateWatchConnection == option ? .white : .red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.leading, 25) 
            }
            
            Button(action: {
                refreshWidgets()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.red)
                        .frame(width: 25)
                    Text("Refresh Widgets")
                        .foregroundColor(.red)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .alert("Widgets Refreshed", isPresented: $showWidgetRefreshAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("All widgets refreshed.")
            }
            
            Button(action: {
                showSplash = true
            }) {
                HStack {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .foregroundColor(.red)
                        .frame(width: 25)
                    Text("Open Onboarding")
                        .foregroundColor(.red)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
        }
    }
}
