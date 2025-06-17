//
//  CumulusWatchApp.swift
//  CumulusWatch Watch App
//
//  Created by Josh Mansfield on 12/06/2025.
//

import SwiftUI

@main
struct CumulusWatch_Watch_AppApp: App {
    @StateObject private var watchConnectivityManager = WatchConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchConnectivityManager)
        }
    }
}
