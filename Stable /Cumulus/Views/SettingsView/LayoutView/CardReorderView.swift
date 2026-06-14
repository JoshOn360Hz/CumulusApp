import SwiftUI

struct CardReorderView: View {
    @StateObject private var cardManager = WeatherCardManager()
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("accentColorName") private var accentColorName: String = "blue"

    private var accentColor: Color {
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
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Customize Cards")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Drag to reorder. Tap the eye to show or hide a card.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

                List {
                    ForEach(cardManager.cardGroupOrder, id: \.id) { group in
                        let visible = cardManager.isVisible(group)
                        HStack(spacing: 14) {
                            // Visibility toggle
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    cardManager.toggleVisibility(group)
                                }
                            } label: {
                                Image(systemName: visible ? "eye.fill" : "eye.slash")
                                    .font(.system(size: 16))
                                    .foregroundColor(visible ? accentColor : .secondary.opacity(0.5))
                                    .frame(width: 24)
                            }
                            .buttonStyle(.plain)

                            // Icons
                            HStack(spacing: -6) {
                                ForEach(Array(group.iconNames.enumerated()), id: \.offset) { index, iconName in
                                    Image(systemName: iconName)
                                        .font(.system(size: 13))
                                        .foregroundColor(visible ? accentColor : .secondary.opacity(0.4))
                                        .frame(width: 22, height: 22)
                                        .background(
                                            Circle()
                                                .fill(Color(UIColor.systemBackground))
                                                .frame(width: 22, height: 22)
                                        )
                                        .zIndex(Double(group.iconNames.count - index))
                                }
                            }
                            .frame(width: max(24, Double(group.iconNames.count) * 14 + 8))

                            // Labels
                            VStack(alignment: .leading, spacing: 2) {
                                Text(group.displayName)
                                    .font(.body)
                                    .foregroundColor(visible ? .primary : .secondary)
                                Text(group.isSmallGroup ? "Small card" : "Large card")
                                    .font(.caption)
                                    .foregroundColor(.secondary.opacity(visible ? 1 : 0.5))
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .opacity(visible ? 1 : 0.5)
                    }
                    .onMove(perform: cardManager.moveCardGroup)
                }
                .listStyle(.plain)
                .environment(\.editMode, .constant(.active))

                Button {
                    cardManager.resetToDefault()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Reset to Default")
                    }
                    .foregroundColor(accentColor)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12).fill(accentColor.opacity(0.1)))
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(accentColor)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .interactiveDismissDisabled()
    }
}
