//
//  ForecastView.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import SwiftUI

struct ForecastView: View {
    @StateObject private var viewModel: ForecastViewModel
    init(location: SavedLocation, initialWeather: WeatherModel?) {
        _viewModel = StateObject(wrappedValue: ForecastViewModel(location: location, initialWeather: initialWeather))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.weatherModel == nil { // Show loading only if no data at all
                 ProgressView("Loading Forecast...")
            } else if let weather = viewModel.weatherModel {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) { // Increased spacing
                        // 1. Current Day Details View
                        CurrentDayDetailsView(
                            current: weather.current,
                            locationName: viewModel.location.name
                        )
                        .padding(.horizontal) // Add horizontal padding to the card itself

                        // 2. Hourly Forecast Horizontal List
                        if let hourly = weather.hourly, !hourly.isEmpty {
                            HourlyForecastView(
                                hourlyForecasts: hourly,
                                formatTime: { timestamp in
                                    viewModel.formattedTime(from: timestamp)
                                }
                            )
                            // HourlyForecastView has its own internal padding
                        }
                        
                        // 3. Daily Forecast Vertical List
                        if !weather.daily.isEmpty {
                            VStack(alignment: .leading) { // Wrap daily forecast in a VStack for title
                                Text("Next \(weather.daily.count) Days")
                                   .font(.title3).bold()
                                   .padding(.leading) // Match HourlyForecastView title padding
                                   .padding(.bottom, 5)

                                ForEach(weather.daily) { forecast in
                                    ForecastCardView(
                                        forecast: forecast,
                                        formattedDate: viewModel.formattedDate(from: forecast.dt)
                                    )
                                }
                            }
                            .padding(.horizontal) // Add horizontal padding for the daily cards section
                        }
                        
                        Spacer() // Pushes content up if ScrollView content is short
                    }
                    .padding(.top) // Add some padding at the very top of the ScrollView
                }
            } else if let errorMessage = viewModel.errorMessage {
                 errorView(message: errorMessage)
            } else {
                Text("No forecast data available.")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("\(viewModel.location.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { // Add a refresh button to the toolbar
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.refreshForecast()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
        }
        .onAppear {
            // Fetch only if data is missing (initialWeather was nil)
            if viewModel.weatherModel == nil {
                viewModel.fetchForecastIfNeeded()
            }
        }
    }

private func errorView(message: String) -> some View {
    VStack(spacing: 15) {
        Spacer()
        Image(systemName: "exclamationmark.triangle.fill")
            .resizable().scaledToFit().frame(width: 50)
            .symbolRenderingMode(.multicolor)
        Text("Error Loading Forecast")
            .font(.title2).fontWeight(.semibold)
        Text(message)
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        Button("Retry") {
            viewModel.refreshForecast() // Use refresh to clear and fetch
        }
        .buttonStyle(.borderedProminent)
        .padding(.top)
        Spacer()
    }
    .padding()
}
}

#Preview {
    NavigationView {
        ForecastView(
            location: SavedLocation(name: "Cupertino", state: "CA", country: "US", lat: 37.3, lon: -122.0),
            initialWeather: nil
        )
    }
}
