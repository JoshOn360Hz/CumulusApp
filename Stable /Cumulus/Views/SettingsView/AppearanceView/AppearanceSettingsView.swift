import SwiftUI

struct AppearanceSettingsView: View {
    @Binding var accentColorName: String
    @Binding var colorScheme: String
    @Binding var currentIcon: String?
    @AppStorage("cardBackgroundStyle") private var cardBackgroundStyle: String = "ultraThin"

    let accentColorOptions: [(name: String, color: Color)]
    var accentColor: Color

    var body: some View {
        Section("Appearance") {
            AccentColorPickerView(accentColorName: $accentColorName, accentColorOptions: accentColorOptions)

            ColorSchemePickerView(colorScheme: $colorScheme)

            NavigationLink(destination: AppIconPickerView(currentIcon: $currentIcon)) {
                HStack {
                    Image(systemName: "app.fill")
                        .foregroundColor(accentColor)
                        .frame(width: 25)
                    Text("App Icon")
                    Spacer()
                }
            }

            // Card style picker
            Picker(selection: $cardBackgroundStyle) {
                ForEach(CardBackgroundStyle.allCases, id: \.rawValue) { style in
                    Text(style.displayName).tag(style.rawValue)
                }
            } label: {
                HStack {
                    Image(systemName: "rectangle.fill")
                        .foregroundColor(accentColor)
                        .frame(width: 25)
                    Text("Card Style")
                }
            }
            .pickerStyle(.menu)
        }
    }
}
