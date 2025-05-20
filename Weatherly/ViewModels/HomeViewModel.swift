//
//  HomeViewModel.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import Combine
import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    // State for the list view
    @Published var savedLocations: [SavedLocation] = []
    @Published var weatherData: [UUID: WeatherModel] = [:]  // Weather data keyed by location ID
    @Published var locationStates: [UUID: LocationCardState] = [:]  // Loading state per location

    // State for city search (used when adding new locations)
    @Published var cityInputForSearch: String = ""
    @Published var searchResults: [GeocodeResponse] = []
    @Published var isSearching: Bool = false
    @Published var searchErrorMessage: String?

    // Dependencies
    private let weatherService: WeatherFetchingService
    private var cancellables = Set<AnyCancellable>()

    // UserDefaults keys for persistence
    private let savedLocationsKey = "savedLocationsData"
    private let lastUpdatedKey = "lastUpdatedData"

    // Cache for last updated timestamps per location
    private var lastUpdated: [UUID: Date] = [:]

    // Enum for card state in the UI
    enum LocationCardState: Equatable {
        case idle, loading, loaded
        case error(String)
    }

    init(weatherService: WeatherFetchingService = WeatherAPIService()) {
        self.weatherService = weatherService
        loadLocations()  // Load saved locations from persistence
        loadLastUpdated()  // Load cached last-updated timestamps
        // Note: We don't fetch weather here; fetching occurs on view .onAppear or via pull-to-refresh.
    }

    // MARK: - Location Persistence

    private func loadLocations() {
        guard let data = UserDefaults.standard.data(forKey: savedLocationsKey)
        else {
            #if DEBUG
                print("No saved locations data found.")
            #endif
            self.savedLocations = []
            return
        }
        do {
            let decoder = JSONDecoder()
            self.savedLocations = try decoder.decode(
                [SavedLocation].self,
                from: data
            )
            #if DEBUG
                print("Loaded \(self.savedLocations.count) locations.")
            #endif
        } catch {
            print("🔴 Failed to decode saved locations: \(error)")
            self.savedLocations = []
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

    private func loadLastUpdated() {
        guard let data = UserDefaults.standard.data(forKey: lastUpdatedKey)
        else {
            #if DEBUG
                print("No last updated data found.")
            #endif
            self.lastUpdated = [:]
            return
        }
        do {
            let decoder = JSONDecoder()
            let savedDict = try decoder.decode([String: Date].self, from: data)
            // Convert string keys back to UUID
            self.lastUpdated = savedDict.reduce(into: [UUID: Date]()) {
                result,
                entry in
                if let uuid = UUID(uuidString: entry.key) {
                    result[uuid] = entry.value
                }
            }
            #if DEBUG
                print(
                    "Loaded last updated timestamps for \(self.lastUpdated.count) locations."
                )
            #endif
        } catch {
            print("🔴 Failed to decode last updated timestamps: \(error)")
            self.lastUpdated = [:]
        }
    }

    private func saveLastUpdated() {
        do {
            let encoder = JSONEncoder()
            // Convert UUID keys to String for storage
            let dictToSave = Dictionary(
                uniqueKeysWithValues: lastUpdated.map {
                    ($0.key.uuidString, $0.value)
                }
            )
            let data = try encoder.encode(dictToSave)
            UserDefaults.standard.set(data, forKey: lastUpdatedKey)
            #if DEBUG
                print(
                    "Saved last updated timestamps for \(lastUpdated.count) locations."
                )
            #endif
        } catch {
            print("🔴 Failed to encode last updated timestamps: \(error)")
        }
    }

    // MARK: - Location Management

    func addLocation(from geocode: GeocodeResponse) {
        guard let newLocation = SavedLocation(from: geocode) else { return }
        // Avoid adding duplicates (matching by coordinates)
        let isDuplicate = savedLocations.contains {
            abs($0.lat - newLocation.lat) < 0.001
                && abs($0.lon - newLocation.lon) < 0.001
        }
        if !isDuplicate {
            savedLocations.append(newLocation)
            saveLocations()
            // Fetch weather immediately for the newly added location
            fetchWeatherIfNeeded(for: newLocation)
        } else {
            print("Location already saved.")
        }
    }

    func deleteLocation(at offsets: IndexSet) {
        // Remove associated weather data and state before removing location
        let idsToRemove = offsets.map { savedLocations[$0].id }
        idsToRemove.forEach { id in
            weatherData.removeValue(forKey: id)
            locationStates.removeValue(forKey: id)
            lastUpdated.removeValue(forKey: id)
        }
        // Remove from saved list and persist
        savedLocations.remove(atOffsets: offsets)
        saveLocations()
        saveLastUpdated()
    }

    // MARK: - Weather Fetching (Per Location)

    func fetchWeatherIfNeeded(for location: SavedLocation) {
        let locationID = location.id
        let currentState = locationStates[locationID] ?? .idle

        // Only fetch if not already loading, and skip if recently loaded (cache valid < 10 minutes)
        if currentState == .loading {
            #if DEBUG
                print(
                    "Weather fetch skipped for \(location.name) (Already loading)"
                )
            #endif
            return
        }
        if currentState == .loaded {
            if let lastFetch = lastUpdated[locationID],
                Date().timeIntervalSince(lastFetch) < 600
            {
                #if DEBUG
                    print(
                        "Weather fetch skipped for \(location.name) (Recently updated)"
                    )
                #endif
                return
            }
            // If loaded but stale (>= 10 minutes old), allow refetch
        }

        #if DEBUG
            print("⚡️ Fetching weather for \(location.name)...")
        #endif
        locationStates[locationID] = .loading

        weatherService.fetchWeatherByCoordinates(
            lat: location.lat,
            lon: location.lon
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else { return }
            switch completion {
            case .finished:
                if self.weatherData[locationID] == nil {
                    // Finished without data – treat as error
                    print(
                        "⚠️ Weather fetch finished but no data for \(location.name)."
                    )
                    self.locationStates[locationID] = .error(
                        "No data received."
                    )
                } else {
                    #if DEBUG
                        print("✅ Weather fetch finished for \(location.name).")
                    #endif
                    // State is already set to .loaded in receiveValue
                }
            case .failure(let error):
                print(
                    "🔴 Weather fetch failed for \(location.name): \(error.localizedDescription)"
                )
                self.locationStates[locationID] = .error("Network error")
                self.weatherData.removeValue(forKey: locationID)
            }
        } receiveValue: { [weak self] weather in
            guard let self = self else { return }
            self.weatherData[locationID] = weather
            self.locationStates[locationID] = .loaded
            self.lastUpdated[locationID] = Date()
            self.saveLastUpdated()
        }
        .store(in: &cancellables)
    }

    // MARK: - Weather Refresh (All Locations)

    /// Refresh weather data for all saved locations (triggered by pull-to-refresh).
    func refreshAllLocations() async {
        guard !savedLocations.isEmpty else { return }
        #if DEBUG
            print(
                "🔄 Refreshing weather for all \(savedLocations.count) locations..."
            )
        #endif

        // Reset each location’s state and remove cached data to force re-fetch
        for location in savedLocations {
            locationStates[location.id] = .idle
            weatherData.removeValue(forKey: location.id)
        }

        // Use DispatchGroup to track completion of all asynchronous fetches
        let group = DispatchGroup()
        for location in savedLocations {
            let loc = location  // capture value for use inside closure
            group.enter()
            weatherService.fetchWeatherByCoordinates(lat: loc.lat, lon: loc.lon)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    defer { group.leave() }  // signal this fetch is done (success or failure)
                    guard let self = self else { return }
                    switch completion {
                    case .finished:
                        if self.weatherData[loc.id] == nil {
                            // No data received despite completion – mark as error
                            self.locationStates[loc.id] = .error(
                                "No data received."
                            )
                            print(
                                "⚠️ Weather refresh finished but no data for \(loc.name)."
                            )
                        } else {
                            #if DEBUG
                                print(
                                    "✅ Weather refresh finished for \(loc.name)."
                                )
                            #endif
                            // State will be .loaded from receiveValue
                        }
                    case .failure(let error):
                        print(
                            "🔴 Weather refresh failed for \(loc.name): \(error.localizedDescription)"
                        )
                        self.locationStates[loc.id] = .error("Network error")
                        self.weatherData.removeValue(forKey: loc.id)
                    }
                } receiveValue: { [weak self] weather in
                    guard let self = self else { return }
                    self.weatherData[loc.id] = weather
                    self.locationStates[loc.id] = .loaded
                    self.lastUpdated[loc.id] = Date()
                }
                .store(in: &cancellables)
        }

        // Wait for all fetch tasks to complete before returning (so that .refreshable can end)
        await withCheckedContinuation { continuation in
            group.notify(queue: .global()) {
                continuation.resume()
            }
        }

        // Persist updated timestamps for all locations
        saveLastUpdated()
    }

    // MARK: - City Search (for Adding Locations)

    func performCitySearch() {
        guard !cityInputForSearch.isEmpty else { return }
        isSearching = true
        searchErrorMessage = nil
        searchResults = []

        weatherService.searchCities(for: cityInputForSearch)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSearching = false
                switch completion {
                case .finished:
                    #if DEBUG
                        print("✅ City search finished.")
                    #endif
                    if self?.searchResults.isEmpty ?? true {
                        self?.searchErrorMessage =
                            "No cities found for '\(self?.cityInputForSearch ?? "")'."
                    }
                case .failure(let error):
                    print("🔴 City search failed: \(error.localizedDescription)")
                    self?.searchErrorMessage = "Failed to search cities."
                }
            } receiveValue: { [weak self] cities in
                self?.searchResults = cities
            }
            .store(in: &cancellables)
    }

    func clearSearchResults() {
        searchResults = []
        cityInputForSearch = ""
        searchErrorMessage = nil
        isSearching = false
    }
}
