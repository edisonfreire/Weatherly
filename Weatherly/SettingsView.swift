//
//  SettingsView.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            Section(Constants.Settings.unitsSectionTitle) {
                Picker(Constants.Settings.temperaturePickerLabel, selection: $viewModel.unit) {
                    ForEach(viewModel.allUnits) { unit in
                        Text(unit.symbol).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Section("Home Location") { /* Add UI later */ }

            // Section("About") { /* Add app version, credits etc. */ }
        }
        .navigationTitle(Constants.Settings.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    // Embed in NavigationView for realistic preview
    NavigationView {
        SettingsView()
    }
}
