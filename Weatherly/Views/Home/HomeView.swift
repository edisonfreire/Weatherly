//
//  HomeView.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    // State to present the Add Location sheet
    @State private var showingAddLocationSheet = false

    var body: some View {
        NavigationStack {
            Group {
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
                AddLocationView(homeViewModel: viewModel)
            }
        }
    }

    // View for the empty state
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "list.star")
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

    // View for the list of saved locations
    private var locationsListView: some View {
        List {
            ForEach(viewModel.savedLocations) { location in
                ZStack {
                    // Make the whole row tappable via invisible NavigationLink
                    NavigationLink(
                        destination: ForecastView(
                            location: location,
                            initialWeather: viewModel.weatherData[location.id]
                        )
                    ) {
                        EmptyView()
                    }
                    .opacity(0)
                    SavedLocationCardView(
                        location: location,
                        weather: viewModel.weatherData[location.id],
                        state: viewModel.locationStates[location.id] ?? .idle
                    )
                    .contentShape(Rectangle())  // Ensure the card area is tappable
                }
                .onAppear {
                    viewModel.fetchWeatherIfNeeded(for: location)
                }
            }
            .onDelete(perform: viewModel.deleteLocation)
            // Extra footer space at bottom of list
            Section {
                EmptyView()
            } footer: {
                Color.clear.frame(height: 10)
            }
        }
        .listStyle(.plain)
        // Pull-to-refresh triggers refreshing all locations
        .refreshable {
            await refreshWeatherData()
        }
    }

    // Toolbar content (Edit and Add buttons, Settings link)
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if !viewModel.savedLocations.isEmpty {
                EditButton()
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                // Reset any previous search state and show Add Location sheet
                viewModel.clearSearchResults()
                showingAddLocationSheet = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .accessibilityLabel("Add Location")
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gear")
                    .accessibilityLabel("Settings")
            }
        }
    }

    // Async refresh action for pull-to-refresh
    private func refreshWeatherData() async {
        await viewModel.refreshAllLocations()
    }
}

#Preview {
    HomeView()
}
