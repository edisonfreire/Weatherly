//
//  ForecastViewModel.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import Combine
import Foundation
import SwiftUI

class ForecastViewModel: ObservableObject {
    @Published var weatherModel: WeatherModel?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let location: SavedLocation

    @AppStorage("temperatureUnit") private var preferredUnit: TemperatureUnit =
        .celsius
    var unitSymbol: String { preferredUnit.symbol }

    private var weatherService: WeatherFetchingService
    private var cancellables = Set<AnyCancellable>()

    // Modified init to accept an optional full WeatherModel
    init(
        location: SavedLocation,
        initialWeather: WeatherModel? = nil,
        weatherService: WeatherFetchingService = WeatherAPIService()
    ) {
        self.location = location
        self.weatherService = weatherService

        if let initialWeather = initialWeather {
            self.weatherModel = initialWeather
            self.isLoading = false
        } else {
            self.isLoading = true  // Will fetch if no initial data
        }
        self.errorMessage = nil
    }

    func fetchForecastIfNeeded() {
            // If we are already loading, let the current fetch complete.
            // If we have data and are not in a loading state (e.g., from a refresh request), don't fetch.
            if isLoading {
                // If isLoading is true, it means a fetch is intended (either initial or via refreshForecast).
                // The guard below will allow the fetch to proceed.
            } else if weatherModel != nil && !isLoading {
                // We have data and no explicit refresh was triggered that set isLoading = true
                #if DEBUG
                print("ℹ️ Forecast fetch skipped: Data already available and not in loading state for \(location.name).")
                #endif
                return
            }

            // Proceed to fetch if weatherModel is nil OR if isLoading was true (set by refreshForecast or initial load)
            // This guard is now simpler: just ensures we don't start *another* fetch if one is already running from a different entry point
            // However, the primary gatekeeping is done by the isLoading flag and weatherModel check above.
            // For clarity, we'll ensure isLoading is true before proceeding.
            // If not already loading, and weatherModel is nil, we start loading.
            if weatherModel == nil && !isLoading {
                isLoading = true
            } else if !isLoading { // This case (weatherModel != nil and !isLoading) is handled by the return above.
                // This path should ideally not be hit if logic above is correct.
                // If weatherModel is not nil, and isLoading is false, we shouldn't be here.
                return
            }
            
            // If !isLoading was true before this point (meaning we are not in an active loading state from refreshForecast),
            // and weatherModel is nil, we need to set isLoading = true.
            // The refreshForecast() method already sets isLoading = true.
            // The init() sets isLoading = true if initialWeather is nil.

            // Simplified logic:
            // If a fetch is already in progress (isLoading is true from elsewhere), don't stack another.
            // This is slightly redundant if calls are strictly managed, but safe.
            // The primary condition to fetch is: (weatherModel == nil) OR (a refresh was called that set isLoading = true)

            // Let's refine the entry condition:
            // Fetch if (isLoading is true) OR (weatherModel is nil)
            // If isLoading is false AND weatherModel exists, then return.
            
            if !isLoading && weatherModel != nil {
                #if DEBUG
                print("ℹ️ Forecast fetch skipped: Data exists and not forced by isLoading state for \(location.name).")
                #endif
                return
            }

            // If we reach here, either isLoading is true (refresh scenario) or weatherModel is nil (initial load).
            // Ensure isLoading is true for the fetch operation.
            if !isLoading { // This will be true if weatherModel is nil and isLoading was false.
                isLoading = true
            }
            
            errorMessage = nil // Clear previous errors

            #if DEBUG
            print("🔄 Fetching forecast for \(location.name)... (isLoading: \(isLoading), weatherModel is nil: \(weatherModel == nil))")
            #endif

            weatherService.fetchWeatherByCoordinates(lat: location.lat, lon: location.lon)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    // Only set isLoading to false when the fetch operation actually finishes or fails.
                    self?.isLoading = false
                    switch completion {
                    case .finished:
                         #if DEBUG
                         print("✅ Forecast fetch finished for \(self?.location.name ?? "")")
                         #endif
                         if self?.weatherModel == nil {
                            self?.errorMessage = "No forecast data available after fetch."
                         }
                    case .failure(let error):
                        print("🔴 Forecast fetch failed for \(self?.location.name ?? ""): \(error.localizedDescription)")
                        self?.errorMessage = "Could not load forecast: \(error.localizedDescription)"
                    }
                }, receiveValue: { [weak self] weatherData in
                    self?.weatherModel = weatherData
                    // isLoading is set to false in receiveCompletion
                })
                .store(in: &cancellables)
        }

    func refreshForecast() {
        // Force a refresh, even if data exists
        weatherModel = nil  // Clear existing model to ensure fetch
        isLoading = true  // Set loading state
        fetchForecastIfNeeded()
    }

    // MARK: - Formatting Helpers

    func formattedDate(from timestamp: Int, format: String = "EEEE, MMM d")
        -> String
    {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return DateFormatterCache.formatter(for: format).string(from: date)
    }

    func formattedTime(from timestamp: Int, format: String = "h a") -> String
    {  // e.g., 3 PM
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return DateFormatterCache.formatter(for: format).string(from: date)
    }
}

// Helper to cache DateFormatters (improves performance in lists)
// (Keep DateFormatterCache as is)
struct DateFormatterCache {
    static private var formatters: [String: DateFormatter] = [:]

    static func formatter(for format: String) -> DateFormatter {
        if let existingFormatter = formatters[format] {
            return existingFormatter
        }
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = format
        formatters[format] = newFormatter
        return newFormatter
    }
}
