//
//  PrecipitationCardView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 13/06/2025.
//


import SwiftUI


struct PrecipitationCardView: View {
    let precipitation: Double?
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Precipitation")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Image(systemName: "drop.fill")
                .font(.title)
                .foregroundColor(.white)
            
            if let precip = precipitation {
                Text("\(precip, specifier: "%.1f") mm")
                    .font(.callout)
                    .foregroundColor(.white)
            } else {
                Text("-- mm")
                    .font(.callout)
                    .foregroundColor(.white)
            }
        }
        .smallGlassCard()
    }
}