//
//  SunTimesCardView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 12/06/2025.
//

import SwiftUI


struct SunTimesCardView: View {
    let sunrise: String
    let sunset: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Sun Times")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 30) {
                VStack(spacing: 2) {
                    Image(systemName: "sunrise.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Text(sunrise)
                        .font(.caption2)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 2) {
                    Image(systemName: "sunset.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Text(sunset)
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
        }
        .smallGlassCard()
    }
}
