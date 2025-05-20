//
//  Constants.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import Foundation

struct Constants {

    struct Home {
        static let title = "Weather Locations" // Updated title
        static let findCityPrompt = "Tap the '+' button to search and add a city."
        static let loadingMessage = "Loading..." // Might not be needed globally now
        static let noSavedLocations = "No Saved Locations"
    }

    struct SearchResults {
        static let navigationTitle = "Select City"
        // Add other strings used in SearchResultsView here
    }

    struct Settings {
        static let navigationTitle = "Settings"
        static let unitsSectionTitle = "Units"
        static let temperaturePickerLabel = "Temperature"
    }

}
