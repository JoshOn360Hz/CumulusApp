//
//  WeatherWidgetBackground.swift
//  Cumulus
//
//  Created by Josh Mansfield on 29/05/2025.
//

import SwiftUI

func backgroundGradient(for symbol: String, isDaytime: Bool) -> LinearGradient {
    let lower = symbol.lowercased()

    if lower.contains("drizzle") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.gray.opacity(0.6)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom)

    } else if lower.contains("light.rain") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.gray], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.blue], startPoint: .top, endPoint: .bottom)

    } else if lower.contains("heavy.rain") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.gray.opacity(0.4)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.black, Color.blue.opacity(0.8)], startPoint: .top, endPoint: .bottom)

    } else if lower.contains("rain") {
        return isDaytime ?
            LinearGradient(colors: [Color.blue, Color.gray], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.gray, Color.blue], startPoint: .top, endPoint: .bottom)
    }
    else if symbol.contains("thermometer.sun") {
       return isDaytime ?
           LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]),
                          startPoint: .top, endPoint: .bottom)
           : LinearGradient(gradient: Gradient(colors: [Color.black, Color.red]),
                            startPoint: .top, endPoint: .bottom)
       
   } else if symbol.contains("cloud") {
       return isDaytime ?
           LinearGradient(gradient: Gradient(colors: [Color.gray, Color.gray]),
                          startPoint: .top, endPoint: .bottom)
           : LinearGradient(colors: [Color.black, Color.indigo], startPoint: .top, endPoint: .bottom)
       
   } else if symbol.contains("wind") {
       return isDaytime ?
           LinearGradient(gradient: Gradient(colors: [Color.mint, Color.blue]),
                          startPoint: .top, endPoint: .bottom)
           : LinearGradient(gradient: Gradient(colors: [Color.black, Color.mint.opacity(0.6)]),
                            startPoint: .top, endPoint: .bottom)
       
   } else if symbol.contains("cloud.sun") {
       return isDaytime ?
           LinearGradient(gradient: Gradient(colors: [Color.gray, Color.blue]),
                          startPoint: .top, endPoint: .bottom)
           : LinearGradient(colors: [Color.black, Color.indigo], startPoint: .top, endPoint: .bottom)
       
   }

    return isDaytime ?
        LinearGradient(colors: [Color.blue.opacity(0.7), Color.cyan], startPoint: .top, endPoint: .bottom) :
        LinearGradient(colors: [Color.black, Color.indigo], startPoint: .top, endPoint: .bottom)
}
