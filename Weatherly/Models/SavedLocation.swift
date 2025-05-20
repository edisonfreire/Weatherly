//
//  SavedLocation.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import Foundation

struct SavedLocation: Codable, Identifiable, Hashable { // Hashable needed for Dictionary keys
    let id: UUID // Use UUID for a stable ID
    var name: String
    var state: String?
    var country: String
    var lat: Double
    var lon: Double

    // Helper for display
    var displayString: String {
        var components = [name]
        if let state = state, !state.isEmpty {
            components.append(state)
        }
        components.append(country)
        return components.joined(separator: ", ")
    }

    // Provide a default initializer if needed elsewhere
    init(id: UUID = UUID(), name: String, state: String? = nil, country: String, lat: Double, lon: Double) {
        self.id = id
        self.name = name
        self.state = state
        self.country = country
        self.lat = lat
        self.lon = lon
    }

    // Convenience initializer from GeocodeResponse (assuming GeocodeResponse exists)
    // Might need to re-add GeocodeResponse if it was part of WeatherModel
    init?(from geocode: GeocodeResponse?) {
        guard let geocode = geocode else { return nil }
        self.init(name: geocode.name, state: geocode.state, country: geocode.country, lat: geocode.lat, lon: geocode.lon)
    }
}

struct GeocodeResponse: Codable, Identifiable, Hashable {
    var id: String { "\(name)-\(lat)-\(lon)" }
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?

    // Add Equatable conformance if needed
    static func == (lhs: GeocodeResponse, rhs: GeocodeResponse) -> Bool {
        lhs.lat == rhs.lat && lhs.lon == rhs.lon && lhs.name == rhs.name
    }

    // Need Hashable for potential use in Sets or Dictionary keys if needed
    func hash(into hasher: inout Hasher) {
        hasher.combine(lat)
        hasher.combine(lon)
        hasher.combine(name)
    }
}
