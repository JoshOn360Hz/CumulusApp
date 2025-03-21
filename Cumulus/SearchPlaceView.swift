import SwiftUI
import CoreLocation
import Combine

struct RoundedTopCornersShape: Shape {
    let cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: cornerRadius),
            control: CGPoint(x: rect.width, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    return frame.height
                }
                return 0
            }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}


struct SearchPlaceView: View {
    @Binding var isPresented: Bool
    let onPlaceSelected: (CLLocation) -> Void

    @State private var searchText: String = ""
    @State private var searchResults: [CLPlacemark] = []
    @State private var additionalOffset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0.0
    @FocusState private var searchFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    // This constant moves the sheet down further when keyboard is hidden.
    private let hiddenOffset: CGFloat = 35

    var body: some View {
        GeometryReader { geometry in
            let baseSheetHeight = geometry.size.height * 0.35
            let extraSheetHeight = keyboardHeight * 0.30
            let computedSheetHeight = baseSheetHeight + extraSheetHeight

            ZStack(alignment: .bottom) {
                if isPresented {
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        }
                }
                
                if isPresented {
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 40, height: 5)
                            .padding(.vertical, 10)
                        
                        ZStack(alignment: .trailing) {
                            TextField("Search for a City", text: $searchText, onCommit: {
                                performSearch()
                            })
                            .multilineTextAlignment(.center)            // Center the text itself
                            .focused($searchFieldFocused)
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 20)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                            .frame(maxWidth: .infinity, alignment: .center) // Center the whole field in its container
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.trailing, 30)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        
                        // Only show up to 2 search results.
                        List(Array(searchResults.prefix(2)), id: \.self) { placemark in
                            Text(placeDisplayName(placemark))
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 20)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Capsule())
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .onTapGesture {
                                    if let loc = placemark.location {
                                        onPlaceSelected(loc)
                                    }
                                    withAnimation(.spring()) {
                                        additionalOffset = geometry.size.height
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isPresented = false
                                        additionalOffset = 0 // Reset for next use
                                    }
                                }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                    .frame(height: computedSheetHeight)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedTopCornersShape(cornerRadius: 20))
                    .overlay(
                        RoundedTopCornersShape(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    // Apply an extra offset when the keyboard is dismissed.
                    .offset(y: dragOffset + additionalOffset + (keyboardHeight == 0 ? hiddenOffset : 0))
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                // If dragging downward more than 40 points, dismiss the keyboard.
                                if value.translation.height > 40 {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                                if value.translation.height > 0 {
                                    state = value.translation.height
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > 100 {
                                    withAnimation(.spring()) {
                                        isPresented = false
                                    }
                                }
                            }
                    )
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: isPresented)
                    .edgesIgnoringSafeArea(.bottom)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            searchFieldFocused = true
                        }
                    }
                }
            }
            .onReceive(Publishers.keyboardHeight) { height in
                withAnimation(.easeOut(duration: 0.25)) {
                    // Adjust using a multiplier as needed.
                    self.keyboardHeight = height * 0.001
                }
            }
        }
    }
    
    private func placeDisplayName(_ placemark: CLPlacemark) -> String {
        var parts: [String] = []
        if let name = placemark.name { parts.append(name) }
        if let locality = placemark.locality { parts.append(locality) }
        if let country = placemark.country { parts.append(country) }
        return parts.joined(separator: ", ")
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchText) { placemarks, error in
            if let error = error {
                print("Geocode error: \(error.localizedDescription)")
            }
            self.searchResults = placemarks ?? []
            print("Returned \(self.searchResults.count) results")
        }
    }
}
