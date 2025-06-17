//
//  GlassCardBackground.swift
//  CumulusWatch Watch App
//
//  Created by Josh Mansfield on 12/06/2025.
//

import SwiftUI

struct GlassCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(.ultraThinMaterial)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardBackground())
    }
}
