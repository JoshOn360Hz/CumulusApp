import SwiftUI

struct IconOptionView: View {
    let option: (name: String, filename: String?)
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
            iconImage
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
    
    private var iconImage: Image {
#if canImport(UIKit)
        if let uiImage = UIImage(named: option.filename ?? "icon-glass-picker") {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "app.fill")
        }
#else
        return Image(systemName: "app.fill")
#endif
    }
}
