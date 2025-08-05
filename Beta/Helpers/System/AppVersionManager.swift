//
//  AppVersionManager.swift
//  Cumulus
//
//  Created by Josh Mansfield on 30/05/2025.
//


import Foundation

struct AppVersionManager {
    static let key = "lastLaunchedVersion"

    static func isNewVersion() -> Bool {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let lastVersion = UserDefaults.standard.string(forKey: key)

        if currentVersion != lastVersion {
            UserDefaults.standard.set(currentVersion, forKey: key)
            return true
        }
        return false
    }
}