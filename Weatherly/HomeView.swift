//
//  HomeView.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    // State to present the Add Location Sheet
    @State private var showingAddLocationSheet = false

    var body: some View {
        NavigationStack {
            Group { // Use Group to easily switch content
                if viewModel.savedLocations.isEmpty {
                    emptyStateView
                } else {
                    locationsListView
                }
            }
            .navigationTitle(Constants.Home.title)
            .toolbar { toolbarContent }
            // Sheet for adding new locations
            .sheet(isPresented: $showingAddLocationSheet) {
                 // Pass necessary parts of the HomeViewModel or create a dedicated AddLocationViewModel
                 AddLocationView(homeViewModel: viewModel)
            }
        }
    }

    // View for the empty state
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "list.star") // Example icon
                 .resizable()
                 .scaledToFit()
                 .frame(width: 80, height: 80)
                 .foregroundColor(.secondary)
            Text(Constants.Home.noSavedLocations)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)
            Text(Constants.Home.findCityPrompt)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
         }
         .padding()
    }

    // View for the list of locations
    private var locationsListView: some View {
            List {
                ForEach(viewModel.savedLocations) { location in
                    ZStack { // Use ZStack to make the whole row tappable via NavigationLink
                        // MODIFIED: Pass the full WeatherModel object for the location
                        NavigationLink(destination: ForecastView(location: location, initialWeather: viewModel.weatherData[location.id])) {
                           EmptyView() // NavigationLink requires a label, but we provide it below
                        }
                        .opacity(0) // Make the NavigationLink invisible

                        SavedLocationCardView(
                            location: location,
                            weather: viewModel.weatherData[location.id], // This provides current temp for the card
                            state: viewModel.locationStates[location.id] ?? .idle
                        )
                        .contentShape(Rectangle()) // Ensure the card area is tappable for the link
                    }
                    .onAppear {
                        viewModel.fetchWeatherIfNeeded(for: location)
                    }
                }
                .onDelete(perform: viewModel.deleteLocation)
                // Add section footer for spacing if needed
                 Section { EmptyView() } footer: { Color.clear.frame(height: 10) } // Adds padding at bottom
            }
            .listStyle(.plain)
            .refreshable { await refreshWeatherData() } // Use async version if needed
        }

    // Toolbar content builder
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
         ToolbarItem(placement: .navigationBarLeading) {
             if !viewModel.savedLocations.isEmpty { EditButton() }
         }
         ToolbarItem(placement: .navigationBarTrailing) {
             Button {
                 viewModel.clearSearchResults() // Clear previous search state first
                 showingAddLocationSheet = true // Present the sheet
             } label: {
                 Image(systemName: "plus.circle.fill")
                     .accessibilityLabel("Add Location")
             }
         }
         ToolbarItem(placement: .navigationBarTrailing) {
              NavigationLink { SettingsView() } label: {
                  Image(systemName: "gear")
                      .accessibilityLabel("Settings")
              }
         }
    }

    // Async function for refreshable if needed
    private func refreshWeatherData() async {
        // TODO: Implement logic in ViewModel to re-fetch weather for all current locations
        // viewModel.refreshAllLocations() or similar
        print("Refresh triggered - Implement VM logic")
    }
}

#Preview {
    HomeView()
}
