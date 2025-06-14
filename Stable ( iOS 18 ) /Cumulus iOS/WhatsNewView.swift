import SwiftUI

struct WhatsNewSheet: View {
    @Binding var showSheet: Bool
    @GestureState private var dragOffset: CGFloat = 0.0
    @State private var currentIndex = 0

    let icons = [
        "icon-light", "icon-blue", "icon-dark", "icon-purple",
        "icon-red", "icon-teal", "icon-green", "icon-purp",
        "icon-pink", "icon-bear", "icon-cat", "icon-dog",
        "icon-fox", "icon-penguin", "icon-shark"
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            
            Color.black.background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) {
                        showSheet = false
                    }
                }

            VStack {
                Spacer()

                // Cycling Icon
                Image(uiImage: UIImage(named: icons[currentIndex]) ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentIndex = (currentIndex + 1) % icons.count
                            }
                        }
                    }

                // Title
                Text("New in version 2.0")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top, 20)

                // Feature list
                VStack(alignment: .leading, spacing: 20) {
                    Label("1 new large widget", systemImage: "square.grid.2x2.fill")
                    Label("Choose °C or °F in Settings", systemImage: "thermometer")
                    Label("Choose an app icon in Settings ", systemImage: "app.fill")
                    Label("New horizontal layout for iPad", systemImage: "ipad.landscape")
                    Label("Revised gradients for a fresh new look", systemImage: "paintbrush.pointed.fill")

                }
                .foregroundColor(.white)
                .font(.headline)
                .padding(.top, 32)

                Spacer()

                // Continue button
                Button {
                    withAnimation(.spring()) {
                        showSheet = false
                    }
                } label: {
                    Text("Continue")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(GlassButtonStyle())
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
            .padding(.horizontal)
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
        }
        .transition(.move(edge: .bottom))
        .animation(.spring(), value: showSheet)
    }
}
