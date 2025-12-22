//
//  WatchSettingsView.swift
//  Cumulus
//
//  Created by Josh Mansfield on 12/06/2025.
//

import SwiftUI

struct WatchSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var watchManager = WatchConnectivityManager.shared
    @AppStorage("accentColorName") private var accentColorName: String = "blue"
    
    @State private var selectedCards: Set<WeatherCardType> = []
    @State private var showConnectionAlert = false
    @State private var showResetConfirmation = false
    
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
    
    private let availableCards: [WeatherCardType] = [
        .windDirection,
        .feelsLike,
        .visibility,
        .precipitation,
        .pressure,
        .uvIndex,
        .sunTimes
    ]
    
    private let defaultCards: [WeatherCardType] = [
        .windDirection,
        .feelsLike,
        .visibility
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Watch Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Choose 3 weather cards to display on your Apple Watch. The main weather card is always shown.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if !watchManager.isWatchPaired {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("No Apple Watch paired with this iPhone.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding(.top, 4)
                    } else if !watchManager.isWatchConnected {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Apple Watch not reachable.")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 4)
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Apple Watch connected")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                List {
                    if !watchManager.isWatchPaired {
                        Section {
                            Spacer()
                            HStack {
                                VStack(spacing: 12) {
                                    Image(systemName: "applewatch.slash")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary)
                                    Text("No Apple Watch Paired")
                                        .font(.headline)
                                    Text("Pair an Apple Watch with this iPhone in the Watch app to use these features.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 30)
                            .listRowBackground(Color.clear)
                        }
                    } else {
                        ForEach(availableCards, id: \.id) { cardType in
                            CardSelectionRow(
                                cardType: cardType,
                                isSelected: selectedCards.contains(cardType),
                                accentColor: accentColor
                            ) {
                                toggleCardSelection(cardType)
                            }
                        }
                    }
                }
                .disabled(!watchManager.isWatchPaired)
                .listStyle(PlainListStyle())
                
                Button(action: {
                    showResetConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Reset to Default Cards")
                    }
                    .foregroundColor(watchManager.isWatchPaired ? accentColor : .gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(watchManager.isWatchPaired ? accentColor.opacity(0.1) : Color(.systemGray5))
                    )
                }
                .disabled(!watchManager.isWatchPaired)
                .padding()
                .alert("Reset Watch Cards", isPresented: $showResetConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Reset", role: .destructive) {
                        resetToDefaultCards()
                    }
                } message: {
                    Text("This will reset your watch card selection to the default layout. Continue?")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWatchSettings()
                       
                    }
                    .disabled(selectedCards.count != 3 || !watchManager.isWatchPaired)
                    .fontWeight(.semibold)
                    .foregroundColor((selectedCards.count == 3 && watchManager.isWatchPaired) ? accentColor : .secondary)
                }
            }
            .alert("Settings Saved", isPresented: $showConnectionAlert) {
                Button("OK", role: .cancel) { 
                    presentationMode.wrappedValue.dismiss()
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                if !watchManager.isWatchPaired {
                    Text("No Apple Watch is paired with this iPhone. Pair a watch in the Watch app to use these features.")
                } else if !watchManager.isWatchConnected {
                    Text("Cards have been saved and will sync with your Apple Watch.")
                } else {
                    Text("Cards have been saved and synced with your Apple Watch.")
                }
            }
        }
        .onAppear {
            loadCurrentSettings()
        }
    }
    
    private func toggleCardSelection(_ cardType: WeatherCardType) {
        if selectedCards.contains(cardType) {
            selectedCards.remove(cardType)
        } else if selectedCards.count < 3 {
            selectedCards.insert(cardType)
        }
    }
    
    private func loadCurrentSettings() {
        selectedCards = Set(watchManager.selectedWatchCards)
    }
    
    private func saveWatchSettings() {
        let cardsArray = Array(selectedCards)
        watchManager.updateWatchCards(cardsArray)
        
        showConnectionAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func resetToDefaultCards() {
        selectedCards = Set(defaultCards)
    }
}

struct CardSelectionRow: View {
    let cardType: WeatherCardType
    let isSelected: Bool
    let accentColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: cardType.iconName)
                        .foregroundColor(accentColor)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cardType.displayName)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Text(cardType.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? accentColor : .secondary)
                    .font(.title2)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension WeatherCardType {
    var description: String {
        switch self {
        case .windDirection: return "Wind direction and compass"
        case .feelsLike: return "Apparent temperature"
        case .visibility: return "Visibility distance"
        case .precipitation: return "Daily precipitation amount"
        case .pressure: return "Atmospheric pressure"
        case .uvIndex: return "UV index level"
        case .sunTimes: return "Sunrise and sunset times"
        case .forecast: return "5-day weather forecast"
        case .hourlyForecast: return "Next 12 hours forecast"
        }
    }
}

#Preview {
    WatchSettingsView()
}
