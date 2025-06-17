//
//  smallglassmodifier.swift
//
//  Created by Josh Mansfield on 13/06/2025.
//

import SwiftUI

struct SmallGlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
    }
}

extension View {
    func smallGlassCard() -> some View {
        self.modifier(SmallGlassCardModifier())
    }
}
