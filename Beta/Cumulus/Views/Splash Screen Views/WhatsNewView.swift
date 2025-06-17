import SwiftUI

struct WhatsNewSheet: View {
    @Binding var showSheet: Bool
    @AppStorage("accentColorName") private var accentColorName: String = "blue"
    @Environment(\.dismiss) private var dismiss
    
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
            ScrollView {
                VStack(spacing: 32) {
                    // Header Section
                    VStack(spacing: 20) {
                        // App Icon
                        Image(uiImage: UIImage(named: "icon-glass-picker") ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .cornerRadius(26)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 8) {
                            Text("What's New")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Version 3.0")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Features Section
                    VStack(spacing: 24) {
                        FeatureRow(
                            icon: "sparkles.rectangle.stack",
                            title: "Liquid Glass Design",
                            description: "Updated UI and icons to match the Liquid Glass design language",
                            accentColor: accentColor
                        )
                        
                        FeatureRow(
                            icon: "square.grid.3x3",
                            title: "Customizable Cards",
                            description: "Reorder and customize your weather cards in Settings",
                            accentColor: accentColor
                        )
                        
                        FeatureRow(
                            icon: "square.split.2x2.fill",
                            title: "Redesigned Interface",
                            description: "Clean TabView navigation for better user experience",
                            accentColor: accentColor
                        )
                        FeatureRow(
                            icon: "applewatch",
                            title: "Apple Watch App",
                            description: "Introducing the companion app for WatchOS!",
                            accentColor: accentColor
                        )
                        
                        FeatureRow(
                            icon: "ipad.and.arrow.forward",
                            title: "iPadOS 26 Windowing",
                            description: "Updated layout to support windowed mode in iPadOS 26",
                            accentColor: accentColor
                        )
                        
                        FeatureRow(
                            icon: "slider.horizontal.3",
                            title: "More Unit Options",
                            description: "Additional temperature and wind speed unit preferences",
                            accentColor: accentColor
                        )
                        
                        FeatureRow(
                            icon: "magnifyingglass.circle.fill",
                            title: "Enhanced Search",
                            description: "Completely redesigned search interface and experience",
                            accentColor: accentColor
                        )
                        
                        FeatureRow(
                            icon: "gearshape.2.fill",
                            title: "Settings Overhaul",
                            description: "Reorganized settings with improved navigation",
                            accentColor: accentColor
                        )
                        
                        FeatureRow(
                            icon: "paintpalette.fill",
                            title: "Accent Colors",
                            description: "Choose from beautiful accent colors to personalize your experience",
                            accentColor: accentColor
                        )
                        FeatureRow(
                            icon: "checklist",
                            title: "Reimagined Onboarding",
                            description: "Onboarding has been reimagined to guide through customisation.",
                            accentColor: accentColor
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                // Continue Button
                Button(action: {
                    showSheet = false
                }) {
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
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .background(Color(UIColor.systemBackground))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        showSheet = false
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(accentColor)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(accentColor.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}
