import SwiftUI


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

