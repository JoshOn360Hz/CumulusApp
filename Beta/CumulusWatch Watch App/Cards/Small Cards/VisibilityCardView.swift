//
//  VisibilityCardView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 13/06/2025.
//


import SwiftUI


struct VisibilityCardView: View {
    let visibility: Double
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Visibility")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Image(systemName: "eye.fill")
                .font(.title)
                .foregroundColor(.white)
            
            // Convert from meters to kilometers
            Text("\(visibility / 1000, specifier: "%.1f") km")
                .font(.callout)
                .foregroundColor(.white)
        }
        .smallGlassCard()
    }
}
