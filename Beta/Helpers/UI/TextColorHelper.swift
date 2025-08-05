//
//  TextColorHelper.swift
//  Cumulus
//
//  Created by Josh Mansfield on 12/06/2025.
//

import SwiftUI

extension Color {
    static func weatherColor(for condition: String?) -> Color {
        if let condition = condition?.lowercased(), condition.contains("cloud") {
            return .black
        }
        return .white
    }
}
