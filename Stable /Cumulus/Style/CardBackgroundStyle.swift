import SwiftUI

enum CardBackgroundStyle: String, CaseIterable {
    case ultraThin = "ultraThin"
    case tinted = "tinted"

    var displayName: String {
        switch self {
        case .ultraThin: return "Ultra Thin"
        case .tinted: return "Tinted"
        }
    }

    var isTinted: Bool { self == .tinted }
}

struct CardBackground: ViewModifier {
    @AppStorage("cardBackgroundStyle") private var style: String = "ultraThin"
    @AppStorage("accentColorName") private var accentColorName: String = "blue"

    private var currentStyle: CardBackgroundStyle {
        CardBackgroundStyle(rawValue: style) ?? .ultraThin
    }

    private var tintColor: Color {
        switch accentColorName {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "purple": return .purple
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        case "mint": return .mint
        default: return .blue
        }
    }

    func body(content: Content) -> some View {
        if currentStyle.isTinted {
            content
                .background(tintColor.opacity(0.15))
                .background(.ultraThinMaterial)
        } else {
            content
                .background(.ultraThinMaterial)
        }
    }
}

extension View {
    func cardBackground() -> some View {
        modifier(CardBackground())
    }
}
