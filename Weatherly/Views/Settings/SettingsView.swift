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
                Picker(
                    Constants.Settings.temperaturePickerLabel,
                    selection: $viewModel.unit
                ) {
                    ForEach(viewModel.allUnits) { unit in
                        Text(unit.symbol).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Appearance") {
                Toggle("Dark Mode", isOn: $viewModel.isDarkMode)
            }

        }
        .navigationTitle(Constants.Settings.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
