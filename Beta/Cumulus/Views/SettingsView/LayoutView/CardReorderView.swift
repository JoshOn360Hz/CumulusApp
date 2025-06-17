//
//  CardReorderView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 11/06/2025.
//

import SwiftUI

struct CardReorderView: View {
    @StateObject private var cardManager = WeatherCardManager()
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("accentColorName") private var accentColorName: String = "blue"
    
    private var selectedAccentColor: Color {
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
                VStack(alignment: .leading, spacing: 12) {
                    Text("Customize Cards")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Drag and drop to reorder your weather card groups. Small cards are automatically paired together for better layout.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Card group list
                List {
                    ForEach(cardManager.cardGroupOrder, id: \.id) { group in
                        HStack {
                            HStack(spacing: -8) {
                                ForEach(Array(group.iconNames.enumerated()), id: \.offset) { index, iconName in
                                    Image(systemName: iconName)
                                        .foregroundColor(selectedAccentColor)
                                        .frame(width: 20, height: 20)
                                        .background(
                                            Circle()
                                                .fill(Color(UIColor.systemBackground))
                                                .frame(width: 20, height: 20)
                                        )
                                        .zIndex(Double(group.iconNames.count - index))
                                }
                            }
                            .frame(width: max(24, Double(group.iconNames.count) * 12 + 8))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(group.displayName)
                                    .font(.body)
                                
                                if group.isSmallGroup {
                                    Text("Small Card Group (\(group.cards.count) cards)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Large Card")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(selectedAccentColor)
                        }
                        .padding(.vertical, 4)
                    }
                    .onMove(perform: cardManager.moveCardGroup)
                }
                .listStyle(PlainListStyle())
                .scrollDisabled(true)
                
                // Reset button
                Button(action: {
                    cardManager.resetToDefault()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Reset to Default Order")
                    }
                    .foregroundColor(selectedAccentColor)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedAccentColor.opacity(0.1))
                    )
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(selectedAccentColor)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .interactiveDismissDisabled()
    }
}
