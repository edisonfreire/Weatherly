//
//  SettingsViewModel.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    // Use @AppStorage to automatically save/load the unit preference
    @AppStorage("temperatureUnit") var unit: TemperatureUnit = .celsius

    // Provides options for the Picker
    let allUnits: [TemperatureUnit] = TemperatureUnit.allCases

    // Add properties/logic for managing home location if implemented
}
