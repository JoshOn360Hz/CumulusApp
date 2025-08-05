import SwiftUI

struct AppIconManager {
    
    static let iconOptions: [(name: String, filename: String?, previewImage: String)] = [
        ("Default", nil, "icon-default-preview"),
        ("Blue", "icon-blue", "icon-blue-preview"),
        ("Dark", "icon-dark", "icon-dark-preview"),
        ("Bubblegum", "icon-purple", "icon-purple-preview"),
        ("Red", "icon-red", "icon-red-preview"),
        ("Teal", "icon-teal", "icon-teal-preview"),
        ("Green", "icon-green", "icon-green-preview"),
        ("Purple", "icon-purp", "icon-purp-preview"),
        ("Pink", "icon-pink", "icon-pink-preview"),
        ("Bear", "icon-bear", "icon-bear-preview"),
        ("Cat", "icon-cat", "icon-cat-preview"),
        ("Dog", "icon-dog", "icon-dog-preview"),
        ("Fox", "icon-fox", "icon-fox-preview"),
        ("Penguin", "icon-penguin", "icon-penguin-preview"),
        ("Shark", "icon-shark", "icon-shark-preview")
    ]
    
    static func changeAppIcon(to iconName: String?) {
        #if canImport(UIKit)
        guard UIApplication.shared.supportsAlternateIcons else { return }
        
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Failed to change icon: \(error.localizedDescription)")
            } else {
                print("App icon changed to: \(iconName ?? "default")")
            }
        }
        #endif
    }
}

struct ModernIconOptionView: View {
    let option: (name: String, filename: String?, previewImage: String)
    let isSelected: Bool
    @AppStorage("accentColorName") private var accentColorName: String = "blue"
    
    var accentColor: Color {
        switch accentColorName {
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
    
    var body: some View {
        VStack(spacing: 8) {
            Image(option.previewImage)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(16)
                .frame(width: 72, height: 72)
            
            Text(option.name)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? accentColor : Color.clear, lineWidth: 3)
        )
    }
}
