//
//  TemperatureConverter.swift
//  Weatherly
//
//  Created by Edison Freire on 5/6/25.
//

import Foundation

// Helper extension on Double for temperature conversions
// Assumes the Double value it's called on is in Celsius.
extension Double {
    func asDisplayTemperature(in unit: TemperatureUnit) -> Double {
        switch unit {
        case .celsius:
            return self // Value is already Celsius
        case .fahrenheit:
            return (self * 9/5) + 32 // Convert Celsius to Fahrenheit
        }
    }
}

