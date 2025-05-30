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
                Text("New in version 1.5")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top, 20)

                // Feature list
                VStack(alignment: .leading, spacing: 20) {
                    Label("2 new Widgets", systemImage: "square.grid.2x2.fill")
                    Label("Custom App Icons", systemImage: "app.fill")
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
