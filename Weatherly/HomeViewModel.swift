//
//  HomeViewModel.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import SwiftUI // Needed for @AppStorage
import Combine
import Foundation // Needed for UserDefaults, JSONEncoder/Decoder

class HomeViewModel: ObservableObject {
    // State for the list view
    @Published var savedLocations: [SavedLocation] = []
    @Published var weatherData: [UUID: WeatherModel] = [:] // Weather keyed by SavedLocation.id
    @Published var locationStates: [UUID: LocationCardState] = [:] // State per location

    // State potentially needed for adding locations (move to separate VM later?)
    @Published var cityInputForSearch: String = "" // Renamed for clarity
    @Published var searchResults: [GeocodeResponse] = []
    @Published var isSearching: Bool = false // Loading state for search
    @Published var searchErrorMessage: String?

    // Dependencies
    private let weatherService: WeatherFetchingService
    private var cancellables = Set<AnyCancellable>()

    // AppStorage key for persistence
    private let savedLocationsKey = "savedLocationsData"

    // Enum for card state
    enum LocationCardState: Equatable { // Equatable needed for guard check
        case idle
        case loading
        case loaded
        case error(String)
    }

    init(weatherService: WeatherFetchingService = WeatherAPIService()) {
        self.weatherService = weatherService
        loadLocations() // Load saved locations on init
        // Don't fetch weather here, wait for .onAppear
    }

    // MARK: - Location Persistence (AppStorage)

    private func loadLocations() {
        guard let data = UserDefaults.standard.data(forKey: savedLocationsKey) else {
            #if DEBUG
            print("No saved locations data found.")
            #endif
            self.savedLocations = [] // Ensure it's empty if no data
            return
        }
        do {
            let decoder = JSONDecoder()
            self.savedLocations = try decoder.decode([SavedLocation].self, from: data)
            #if DEBUG
            print("Loaded \(self.savedLocations.count) locations.")
            #endif
        } catch {
            print("🔴 Failed to decode saved locations: \(error)")
            self.savedLocations = [] // Start fresh if decoding fails
        }
    }

    private func saveLocations() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(savedLocations)
            UserDefaults.standard.set(data, forKey: savedLocationsKey)
            #if DEBUG
            print("Saved \(savedLocations.count) locations.")
            #endif
        } catch {
            print("🔴 Failed to encode locations for saving: \(error)")
        }
    }

    // MARK: - Location Management

    func addLocation(from geocode: GeocodeResponse) {
        let newLocation = SavedLocation(from: geocode)
        guard let validNewLocation = newLocation else { return } // Handle nil case if needed

        // Avoid duplicates based on lat/lon
        if !savedLocations.contains(where: { abs($0.lat - validNewLocation.lat) < 0.001 && abs($0.lon - validNewLocation.lon) < 0.001 }) {
             savedLocations.append(validNewLocation)
             saveLocations()
             // Optionally fetch weather immediately for the newly added location
             fetchWeatherIfNeeded(for: validNewLocation)
        } else {
            print("Location already saved.")
            // Optionally provide feedback to the user
        }
        // Clear search results after adding
        self.searchResults = []
        self.cityInputForSearch = ""
        self.searchErrorMessage = nil
    }

    func deleteLocation(at offsets: IndexSet) {
        // Remove associated weather data and state before removing location
        let idsToRemove = offsets.map { savedLocations[$0].id }
        idsToRemove.forEach { id in
            weatherData.removeValue(forKey: id)
            locationStates.removeValue(forKey: id)
        }
        // Remove location from array
        savedLocations.remove(atOffsets: offsets)
        // Save the updated array
        saveLocations()
    }

    // MARK: - Weather Fetching (Per Card)

    func fetchWeatherIfNeeded(for location: SavedLocation) {
        let locationID = location.id
        let currentState = locationStates[locationID] ?? .idle

        // Only fetch if idle or errored
        guard !(currentState == .loading || currentState == .loaded) else {
                 #if DEBUG
                 // Optional: Log why fetch is skipped
                 print("Weather fetch skipped for \(location.name) (State: \(currentState))")
                 #endif
                return // Exit if already loading or loaded
            }

        #if DEBUG
        print("⚡️ Fetching weather for \(location.name)...")
        #endif

        locationStates[locationID] = .loading

        weatherService.fetchWeatherByCoordinates(lat: location.lat, lon: location.lon)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    if self.weatherData[locationID] == nil {
                         print("⚠️ Weather fetch finished but no data received for \(location.name).")
                         self.locationStates[locationID] = .error("No data received.")
                    } else {
                         #if DEBUG
                         print("✅ Weather fetch finished for \(location.name).")
                         #endif
                         // State already set to .loaded in receiveValue
                    }
                case .failure(let error):
                     print("🔴 Weather fetch failed for \(location.name): \(error.localizedDescription)")
                    self.locationStates[locationID] = .error("Network error") // Simplified error
                    self.weatherData.removeValue(forKey: locationID)
                }
            }, receiveValue: { [weak self] weather in
                self?.weatherData[locationID] = weather
                self?.locationStates[locationID] = .loaded
            })
            .store(in: &cancellables) // Store subscription
    }

    // MARK: - City Search (For Adding Locations - could move to separate VM)

    func performCitySearch() {
        guard !cityInputForSearch.isEmpty else { return }
        isSearching = true
        searchErrorMessage = nil
        searchResults = []

        weatherService.searchCities(for: cityInputForSearch)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isSearching = false
                switch completion {
                case .finished: print("✅ City search finished.")
                     if self?.searchResults.isEmpty ?? true {
                         self?.searchErrorMessage = "No cities found for '\(self?.cityInputForSearch ?? "")'."
                     }
                case .failure(let error):
                    print("🔴 City search failed: \(error.localizedDescription)")
                    self?.searchErrorMessage = "Failed to search cities."
                }
            }, receiveValue: { [weak self] cities in
                 self?.searchResults = cities
            })
            .store(in: &cancellables)
    }

    func clearSearchResults() {
        searchResults = []
        cityInputForSearch = ""
        searchErrorMessage = nil
        isSearching = false
    }
}
