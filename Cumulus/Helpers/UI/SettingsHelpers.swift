import SwiftUI

// Helper extension to manage accent colors consistently across the app
extension Color {
    static func fromAccentName(_ name: String) -> Color {
        switch name.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        case "mint": return .mint
        default: return .blue
        }
    }
}

// Predefined accent color options for reuse
struct AccentColorConstants {
    static let options: [(name: String, color: Color)] = [
        ("Blue", .blue),
        ("Red", .red),
        ("Orange", .orange),
        ("Yellow", .yellow),
        ("Green", .green),
        ("Purple", .purple),
        ("Pink", .pink),
        ("Teal", .teal),
        ("Indigo", .indigo),
        ("Mint", .mint)
    ]
}

// Predefined app icon options for reuse
struct AppIconConstants {
    static let options: [(name: String, filename: String?)] = [
        ("Default", nil), ("Blue", "icon-blue"), ("Dark", "icon-dark"),
        ("Bubblegum", "icon-purple"), ("Red", "icon-red"), ("Teal", "icon-teal"),
        ("Green", "icon-green"), ("Purple", "icon-purp"), ("Pink", "icon-pink"),
        ("Bear", "icon-bear"), ("Cat", "icon-cat"), ("Dog", "icon-dog"),
        ("Fox", "icon-fox"), ("Penguin", "icon-penguin"), ("Shark", "icon-shark")
    ]
}
