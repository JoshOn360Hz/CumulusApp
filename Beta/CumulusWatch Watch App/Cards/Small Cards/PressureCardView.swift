//
//  PressureCardView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 13/06/2025.
//


import SwiftUI

struct PressureCardView: View {
    let pressure: Double
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Pressure")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Image(systemName: "barometer")
                .font(.title)
                .foregroundColor(.white)
            
            Text("\(Int(pressure)) hPa")
                .font(.callout)
                .foregroundColor(.white)
        }
        .smallGlassCard()
    }
}
