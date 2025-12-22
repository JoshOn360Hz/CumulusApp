//
//  GradientHelper.swift
//  Cumulus
//
//  Created by Josh Mansfield on 11/06/2025.
//


import SwiftUI
import WeatherKit

func gradientForWeather(_ weather: Weather?) -> LinearGradient {
    guard let weather = weather else {
        return LinearGradient(colors: [Color.black, Color.indigo], startPoint: .top, endPoint: .bottom)
    }
    
    let isDaytime = weather.currentWeather.isDaylight
    let symbol = weather.currentWeather.symbolName.lowercased()
    
    if symbol.contains("drizzle") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.gray.opacity(0.6)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("light.rain") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.gray], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.blue], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("heavy.rain") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.gray.opacity(0.4)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.blue.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("rain") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.gray], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.blue], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("snow") {
        return isDaytime ?
            LinearGradient(colors: [Color.white, Color.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.white.opacity(0.3)], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("sleet") {
        return isDaytime ?
            LinearGradient(colors: [Color.gray, Color.blue.opacity(0.7)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.gray], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("hail") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue.opacity(0.7), Color.gray], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.blue.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("fog") || symbol.contains("mist") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue.opacity(0.4), Color.gray.opacity(0.6)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.gray], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("overcast") {
        return isDaytime ?
            LinearGradient(colors: [Color.gray, Color.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.gray], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("wind") {
        return isDaytime ?
            LinearGradient(colors: [Color.mint, Color.blue], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.mint.opacity(0.6)], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("cloud.sun") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue.opacity(0.4), Color.gray.opacity(0.6)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.gray], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("sun") {
        return isDaytime ?
            LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.purple, Color.blue], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("thermometer.sun") {
        return isDaytime ?
            LinearGradient(colors: [Color.red, Color.orange], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.red], startPoint: .top, endPoint: .bottom)
        
    } else if symbol.contains("cloud") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue.opacity(0.4), Color.gray.opacity(0.6)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.indigo], startPoint: .top, endPoint: .bottom)
        
    } else {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.indigo], startPoint: .top, endPoint: .bottom)
    }
}
