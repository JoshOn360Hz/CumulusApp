import SwiftUI

struct AppIconPickerView: View {
    @Binding var currentIcon: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 20) {
                ForEach(AppIconManager.iconOptions, id: \.filename) { option in
                    Button {
                        selectIcon(option.filename)
                    } label: {
                        ModernIconOptionView(
                            option: option, 
                            isSelected: option.filename == currentIcon
                        )
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
    
    private func selectIcon(_ iconName: String?) {
        AppIconManager.changeAppIcon(to: iconName)
        currentIcon = iconName
        
#if canImport(UIKit)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
#endif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}
