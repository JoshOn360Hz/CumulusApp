import SwiftUI

struct AccentColorPickerView: View {
    @Binding var accentColorName: String
    let accentColorOptions: [(name: String, color: Color)]

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accent Color")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(accentColorOptions, id: \.name) { option in
                    Button(action: {
                        accentColorName = option.name.lowercased()
                    }) {
                        ZStack {
                            Circle()
                                .fill(option.color)
                                .frame(width: 44, height: 44)
                                .shadow(color: Color(.systemGray3).opacity(0.3), radius: 4, x: 0, y: 2)

                            if accentColorName == option.name.lowercased() {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 18, height: 18)

                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(option.color)
                                }
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.3), value: accentColorName)
                            }
                        }
                        .accessibilityLabel(option.name)
                        .accessibilityAddTraits(accentColorName == option.name.lowercased() ? .isSelected : [])
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
