//
//  WeatherIconView.swift
//  Weatherly
//
//  Created by Edison Freire on 5/6/25.
//

import SwiftUI

struct WeatherIconView: View {
    let iconCode: String
    // var showBackground: Bool = true

    var body: some View {
        Image(systemName: symbolForIconCode(iconCode))
            .resizable()
            .scaledToFit()
            .symbolRenderingMode(.multicolor) // Keep multicolor for weather icons
            .padding(6) // Add some padding so the icon doesn't touch the background edges
            .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 1)
//            .background(
//                // Add a subtle background shape for better contrast
//                Circle()
//                    .fill(Color(.systemGray5)) // Adapts to light/dark mode
//                    // or .systemGray4
//                    // or for a fixed opacity: .fill(Color.black.opacity(0.05)) in light mode
//            )
    }

    // Mapping OpenWeatherMap icon codes to SF Symbols
    private func symbolForIconCode(_ code: String) -> String {
        switch code {
        // Day
        case "01d": return "sun.max.fill"
        case "02d": return "cloud.sun.fill"
        case "03d": return "cloud.fill"          // Predominantly white/gray
        case "04d": return "cloud.fill"          // Often 'broken clouds', cloud.fill is a common choice
        case "09d": return "cloud.drizzle.fill"  // Use drizzle for showers if available
        case "10d": return "cloud.sun.rain.fill"
        case "11d": return "cloud.bolt.rain.fill"
        case "13d": return "snowflake"           // White
        case "50d": return "cloud.fog.fill"      // White/gray

        // Night
        case "01n": return "moon.stars.fill"     // moon.fill can be very light
        case "02n": return "cloud.moon.fill"
        case "03n": return "cloud.fill"
        case "04n": return "cloud.fill"
        case "09n": return "cloud.drizzle.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11n": return "cloud.bolt.rain.fill"
        case "13n": return "snowflake"
        case "50n": return "cloud.fog.fill"
        default: return "questionmark.diamond.fill" // Use a fill version for consistency
        }
    }
}
