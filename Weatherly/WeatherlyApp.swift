//
//  WeatherlyApp.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import SwiftUI

@main
struct WeatherlyApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(
                    isDarkMode ? .dark : nil
                )
        }
    }
}
