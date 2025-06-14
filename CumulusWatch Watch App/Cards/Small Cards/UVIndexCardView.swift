//
//  SmallCardModifierHelper.swift
//  Cumulus
//
//  Created by Josh Mansfield on 13/06/2025.
//


import SwiftUI


struct UVIndexCardView: View {
    let uvIndex: Int
    
    var body: some View {
        VStack(spacing: 5) {
            Text("UV Index")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Image(systemName: "sun.max")
                .font(.title)
                .foregroundColor(.white)
            
            Text("\(uvIndex)")
                .font(.callout)
                .foregroundColor(.white)
        }
        .smallGlassCard()
    }
}
