import SwiftUI

struct SplashScreenView: View {
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "system"
    @AppStorage("accentColorName") private var accentColorName: String = "blue"
    @State private var currentPage = 0
    @State private var selectedIcon: String? = nil
    @StateObject private var watchManager = WatchConnectivityManager.shared
    var onFinish: () -> Void
    
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
    
    let accentColorOptions: [(name: String, color: Color)] = [
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
    
    let iconOptions: [(name: String, filename: String?)] = [
        ("Default", nil), ("Blue", "icon-blue"), ("Dark", "icon-dark"),
        ("Bubblegum", "icon-purple"), ("Red", "icon-red"), ("Teal", "icon-teal"),
        ("Green", "icon-green"), ("Purple", "icon-purp"), ("Pink", "icon-pink"),
        ("Bear", "icon-bear"), ("Cat", "icon-cat"), ("Dog", "icon-dog"),
        ("Fox", "icon-fox"), ("Penguin", "icon-penguin"), ("Shark", "icon-shark")
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Page 1 - Welcome
                welcomeView
                    .tag(0)
                
                // Page 2 - Temperature Unit Selection
                temperatureUnitView
                    .tag(1)
                
                // Page 3 - Accent Color Selection
                accentColorView
                    .tag(2)
                
                // Page 4 - App Icon Selection
                appIconView
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .accentColor(accentColor)
        .onChange(of: temperatureUnit) { oldValue, newValue in
            watchManager.sendUnitsToWatch()
        }
    }
    
    // MARK: - Page Views
    
    private var welcomeView: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 30) {
                Image("applogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(.systemGray3).opacity(0.2), radius: 6, x: 0, y: 3)
                
                VStack(spacing: 8) {
                    Text("Welcome to Cumulus")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Simple | Clean | Weather")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    currentPage = 1
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(accentColor)
                    .cornerRadius(16)
                    .shadow(color: accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 30)
    }
    
    private var temperatureUnitView: some View {
        VStack {
            Spacer()

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Temperature Unit")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Choose your preferred temperature unit")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                VStack(spacing: 12) {
                    temperatureButton(label: "Celsius (°C)", icon: "thermometer", isSelected: temperatureUnit == "celsius") {
                        temperatureUnit = "celsius"
                    }

                    temperatureButton(label: "Fahrenheit (°F)", icon: "thermometer", isSelected: temperatureUnit == "fahrenheit") {
                        temperatureUnit = "fahrenheit"
                    }

                   
                }
                .padding(.horizontal)
            }

            Spacer()
            Button {
                withAnimation {
                    currentPage = 2
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(accentColor)
                    .cornerRadius(16)
                    .shadow(color: accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
    }

    
    private var accentColorView: some View {
        VStack {
            Spacer()

            VStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("Accent Color")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Choose your preferred accent color")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 65), spacing: 20)], spacing: 25) {
                    ForEach(accentColorOptions, id: \.name) { option in
                        Button {
                            accentColorName = option.name.lowercased()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 65, height: 65)
                                    .shadow(color: Color(.systemGray3).opacity(0.3), radius: 4, x: 0, y: 2)

                                if accentColorName == option.name.lowercased() {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 25, height: 25)

                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(option.color)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            Button {
                withAnimation {
                    currentPage = 3
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(accentColor)
                    .cornerRadius(16)
                    .shadow(color: accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
    }

    
    private var appIconView: some View {
        VStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("App Icon")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Choose your preferred app icon")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 20)], spacing: 25) {
                        ForEach(iconOptions, id: \.filename) { option in
                            Button {
                                selectedIcon = option.filename
                                changeAppIcon(to: option.filename)
                            } label: {
                                VStack(spacing: 8) {
                                    ZStack(alignment: .topTrailing) {
                                        iconImage(for: option.filename)
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fit)
                                            .cornerRadius(16)
                                            .frame(width: 75, height: 75)
                                            .shadow(color: Color(.systemGray3).opacity(0.3), radius: 3, x: 0, y: 2)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(selectedIcon == option.filename ? accentColor : Color.clear, lineWidth: 3)
                                            )
                                        
                                        if selectedIcon == option.filename {
                                            ZStack {
                                                Circle()
                                                    .fill(accentColor)
                                                    .frame(width: 24, height: 24)
                                                
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                            .offset(x: 5, y: -5)
                                        }
                                    }

                                    Text(option.name)
                                        .font(.footnote)
                                        .foregroundColor(.primary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
            }

            Spacer()

            Button {
                onFinish()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(accentColor)
                    .cornerRadius(16)
                    .shadow(color: accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
    }

    private func iconImage(for filename: String?) -> Image {
        #if canImport(UIKit)
        if let filename = filename, let uiImage = UIImage(named: filename) {
            return Image(uiImage: uiImage)
        } else {
            return Image(uiImage: UIImage(named: "icon-glass-picker") ?? UIImage())
        }
        #else
        return Image(systemName: "app.fill")
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
}
@ViewBuilder
private func temperatureButton(label: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            Text(label)
            Spacer()
            if isSelected {
                
                Image(systemName: "checkmark")
                    .foregroundColor(Color.accentColor)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    .buttonStyle(.plain)
}
