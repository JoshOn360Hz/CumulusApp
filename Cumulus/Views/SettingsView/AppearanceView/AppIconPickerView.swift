import SwiftUI

struct AppIconPickerView: View {
    @Binding var currentIcon: String?
    @Environment(\.dismiss) private var dismiss
    
    let iconOptions: [(name: String, filename: String?)] = [
        ("Default", nil), ("Blue", "icon-blue"), ("Dark", "icon-dark"),
        ("Bubblegum", "icon-purple"), ("Red", "icon-red"), ("Teal", "icon-teal"),
        ("Green", "icon-green"), ("Purple", "icon-purp"), ("Pink", "icon-pink"),
        ("Bear", "icon-bear"), ("Cat", "icon-cat"), ("Dog", "icon-dog"),
        ("Fox", "icon-fox"), ("Penguin", "icon-penguin"), ("Shark", "icon-shark")
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 20) {
                ForEach(iconOptions, id: \.filename) { option in
                    Button {
                        selectIcon(option.filename)
                    } label: {
                        IconOptionView(option: option, isSelected: option.filename == currentIcon)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("App Icon")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
    
    private func changeAppIcon(to iconName: String?) {
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
    
    private func selectIcon(_ iconName: String?) {
        changeAppIcon(to: iconName)
        currentIcon = iconName
        
        // Haptic feedback
#if canImport(UIKit)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
#endif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}
