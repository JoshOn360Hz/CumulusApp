import SwiftUI

struct IconPickerSheet: View {
    @Binding var showSheet: Bool
    @Binding var showSplash: Bool
    @State private var currentIcon: String? = UIApplication.shared.alternateIconName
    @GestureState private var dragOffset: CGFloat = 0.0

    let iconOptions: [(name: String, filename: String?)] = [
        ("Default", "icon-light"), ("Blue", "icon-blue"), ("Dark", "icon-dark"),
        ("Bubblegum", "icon-purple"), ("Red", "icon-red"), ("Teal", "icon-teal"),
        ("Green", "icon-green"), ("Purple", "icon-purp"), ("Pink", "icon-pink"),
        ("Bear", "icon-bear"), ("Cat", "icon-cat"), ("Dog", "icon-dog"),
        ("Fox", "icon-fox"), ("Penguin", "icon-penguin"), ("Shark", "icon-shark")
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showSheet = false
                        }
                    }

                VStack(spacing: 0) {
                    // Capsule
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.vertical, 10)

                    // Title
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .padding(.top, 10)

                    // Scrollable content
                    ScrollView {
                        VStack(spacing: 24) {

                            // Icon section
                            VStack(spacing: 12) {
                                Text("App Icon")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 20) {
                                    ForEach(iconOptions, id: \.filename) { option in
                                        Button {
                                            changeAppIcon(to: option.filename)
                                            currentIcon = option.filename
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                withAnimation(.spring()) {
                                                    showSheet = false
                                                }
                                            }
                                        } label: {
                                            VStack(spacing: 8) {
                                                Image(uiImage: UIImage(named: option.filename ?? "AppIcon") ?? UIImage())
                                                    .resizable()
                                                    .aspectRatio(1, contentMode: .fit)
                                                    .cornerRadius(16)
                                                    .frame(width: 72, height: 72)

                                                Text(option.name)
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(option.filename == currentIcon ? Color.blue : Color.clear, lineWidth: 3)
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)

                            // Temperature unit section
                            VStack(spacing: 16) {
                                Text("Temperature Unit")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                Button("Change") {
                                    resetApp()

                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        showSheet = false
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            showSplash = true
                                        }
                                    }
                                }
                                .buttonStyle(GlassButtonStyle())
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 60)
                        }
                        .padding(.top, 30)
                    }
                }
                .frame(maxHeight: .infinity)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .clipShape(RoundedTopCornersShape(cornerRadius: 20))
                .overlay(
                    RoundedTopCornersShape(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            if value.translation.height > 0 {
                                state = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 100 {
                                withAnimation(.spring()) {
                                    showSheet = false
                                }
                            }
                        }
                )
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: showSheet)
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }

    func changeAppIcon(to iconName: String?) {
        guard UIApplication.shared.supportsAlternateIcons else { return }

        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Failed to change icon: \(error.localizedDescription)")
            } else {
                print("App icon changed to: \(iconName ?? "default")")
            }
        }
    }
}


func resetApp() {
    if let bundleID = Bundle.main.bundleIdentifier {
        UserDefaults.standard.removePersistentDomain(forName: bundleID)
    }
    
    UserDefaults.standard.set(false, forKey: "hasLaunchedBefore")
}
