//
//  TemperatureUnit.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import Foundation

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case celsius = "metric" // Raw value matches OpenWeatherMap API parameter
    case fahrenheit = "imperial"

    var id: String { self.rawValue }

    var symbol: String { // Helper for display
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}
