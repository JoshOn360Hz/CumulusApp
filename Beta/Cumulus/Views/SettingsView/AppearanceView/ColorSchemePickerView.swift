import SwiftUI

struct ColorSchemePickerView: View {
    @Binding var colorScheme: String
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Color Scheme")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
                
                // Sliding selection indicator
                GeometryReader { geometry in
                    let segmentWidth = geometry.size.width / CGFloat(3)
                    let selectedIndex = colorScheme == "light" ? 1 : (colorScheme == "dark" ? 2 : 0)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(accentColor)
                        .frame(width: segmentWidth - 8) 
                        .padding(4)
                        .offset(x: CGFloat(selectedIndex) * segmentWidth)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: colorScheme)
                }
                
                // Buttons row
                HStack(spacing: 0) {
                    ForEach(["system", "light", "dark"], id: \.self) { scheme in
                        Button(action: {
                            colorScheme = scheme
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: iconForScheme(scheme))
                                    .font(.system(size: 22))
                                    .foregroundColor(colorScheme == scheme ? .white : .secondary)
                                
                                Text(titleForScheme(scheme))
                                    .font(.caption)
                                    .fontWeight(colorScheme == scheme ? .semibold : .regular)
                                    .foregroundColor(colorScheme == scheme ? .white : .primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .frame(height: 80)
        }
        .padding(.vertical, 8)
    }
    
    // Functions for Settings
    
    private func iconForScheme(_ scheme: String) -> String {
        switch scheme {
        case "light":
            return "sun.max.fill"
        case "dark":
            return "moon.fill"
        default:
            return "circle.lefthalf.filled"
        }
    }
    
    private func titleForScheme(_ scheme: String) -> String {
        switch scheme {
        case "light":
            return "Light"
        case "dark":
            return "Dark"
        default:
            return "System"
        }
    }
}
