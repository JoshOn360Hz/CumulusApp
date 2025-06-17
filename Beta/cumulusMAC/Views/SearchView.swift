import SwiftUI
import CoreLocation
import Combine

// MARK: - RoundedTopCornersShape
/// A shape that rounds only the top corners.
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

// MARK: - SearchPlaceView (macOS-friendly)
struct SearchPlaceView: View {
    @Binding var isPresented: Bool
    let onPlaceSelected: (CLLocation) -> Void
    
    @State private var searchText: String = ""
    @State private var searchResults: [CLPlacemark] = []
    
    /// Track a drag gesture offset if you want a “pull‑down to dismiss” effect.
    @GestureState private var dragOffset: CGFloat = 0.0
    
    /// Optional: for automatically focusing the text field on appear
    @FocusState private var searchFieldFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                
                // 1) Dimmed background if presented
                if isPresented {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // Tapping outside closes the sheet
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        }
                }
                
                // 2) The pull-up sheet itself
                if isPresented {
                    VStack(spacing: 0) {
                        // A small capsule “handle” at the top
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 40, height: 5)
                            .padding(.vertical, 10)
                        
                        // The search text field
                        ZStack(alignment: .trailing) {
                            TextField("Search for a City", text: $searchText, onCommit: {
                                performSearch()
                            })
                            .textFieldStyle(.plain)

                            .multilineTextAlignment(.center)
                            .focused($searchFieldFocused)  // optional focus
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 20)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                            .frame(maxWidth: .infinity, alignment: .center)
                   
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        
                        // The search results list (show up to 5 on mac)
                        List(searchResults.prefix(5), id: \.self) { placemark in
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
                                        isPresented = false
                                    }
                                }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                    .frame(height: geometry.size.height * 0.35) // A fixed height for the sheet
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedTopCornersShape(cornerRadius: 35))
                    .overlay(
                        RoundedTopCornersShape(cornerRadius: 35)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: isPresented)
                    .edgesIgnoringSafeArea(.bottom)
                    .onAppear {
                        // Auto-focus the text field after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            searchFieldFocused = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper
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
        }
    }
}
