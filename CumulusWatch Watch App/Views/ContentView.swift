//
//  ContentView.swift
//  CumulusWatch Watch App
//
//  Created by Josh Mansfield on 12/06/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var connectivityManager: WatchConnectivityManager
    @State private var isFirstAppear = true
    
    var body: some View {
        ZStack {
            // Background gradient
            if let weather = connectivityManager.currentWeather {
                backgroundGradient(for: weather.symbolName, isDaytime: weather.isDaytime)
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut(duration: 0.5), value: weather.symbolName)
            } else {
                LinearGradient(
                    colors: [.blue, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            }
            
            if let weather = connectivityManager.currentWeather {
                // Weather content
                ScrollView {
                    VStack(spacing: 8) {
                        // Main weather card (always shown)
                        MainWeatherCardView(weather: weather)
                        
                        // Selected cards (up to 3)
                        ForEach(connectivityManager.selectedCards) { cardType in
                            getCardView(for: cardType, weather: weather)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                }
            } else {
                // Loading state
                VStack(spacing: 10) {
                    Image(systemName: "iphone.gen3")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                    
                    Text("Open Cumulus on your phone")
                        .foregroundColor(.white)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

            }
        }
        .onAppear {
            // Request latest data on every appear
            connectivityManager.requestLatestDataFromPhone()
            if isFirstAppear {
                isFirstAppear = false
            }
        }
        // Add a refresh action if user taps on screen
        .onTapGesture(count: 2) {
            connectivityManager.requestLatestDataFromPhone()
        }
    }
    
    @ViewBuilder
    private func getCardView(for cardType: WeatherCardType, weather: SharedWeather) -> some View {
        switch cardType {
        case .windDirection:
            WindDirectionCardView(
                directionDegrees: weather.windDirection ?? 0,
                windSpeed: weather.windSpeed
            )
        case .feelsLike:
            FeelsLikeCardView(
                feelsLike: weather.feelsLike ?? (weather.temperature - 2)
            )
        case .visibility:
            VisibilityCardView(
                visibility: weather.visibility ?? (weather.symbolName.contains("fog") ? 2.0 : 10.0)
            )
        case .precipitation:
            PrecipitationCardView(
                precipitation: weather.precipitation
            )
        case .pressure:
            PressureCardView(pressure: weather.pressure ?? 1013.0)
        case .uvIndex:
            UVIndexCardView(uvIndex: weather.uvIndex ?? (weather.isDaytime ? 5 : 0))
        case .sunTimes:
            SunTimesCardView(
                sunrise: weather.sunrise ?? "6:30",
                sunset: weather.sunset ?? "20:30"
            )
        default:
            // Other card types not supported on watch
            EmptyView()
        }
    }
}
    
    @ViewBuilder
    private func getCardView(for cardType: WeatherCardType, weather: SharedWeather) -> some View {
        switch cardType {
        case .windDirection:
            WindDirectionCardView(
                directionDegrees: weather.windDirection ?? 0,
                windSpeed: weather.windSpeed
            )
        case .feelsLike:
            FeelsLikeCardView(
                feelsLike: weather.feelsLike ?? (weather.temperature - 2)
            )
        case .visibility:
            VisibilityCardView(
                visibility: weather.visibility ?? (weather.symbolName.contains("fog") ? 2.0 : 10.0)
            )
        case .precipitation:
            PrecipitationCardView(
                precipitation: weather.precipitation
            )
        case .pressure:
            PressureCardView(pressure: weather.pressure ?? 1013.0)
        case .uvIndex:
            UVIndexCardView(uvIndex: weather.uvIndex ?? (weather.isDaytime ? 5 : 0))
        case .sunTimes:
            SunTimesCardView(
                sunrise: weather.sunrise ?? "6:30",
                sunset: weather.sunset ?? "20:30"
            )
        default:
            // Other card types not supported on watch
            EmptyView()
        }
    }


#Preview {
    ContentView()
        .environmentObject(WatchConnectivityManager.shared)
}
