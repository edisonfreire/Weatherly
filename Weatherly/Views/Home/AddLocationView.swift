//
//  AddLocationView.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import SwiftUI

struct AddLocationView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar Area (Keep as is)
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search for a city...", text: $homeViewModel.cityInputForSearch)
                        .textFieldStyle(.plain)
                        .onSubmit { homeViewModel.performCitySearch() }
                    if !homeViewModel.cityInputForSearch.isEmpty {
                        Button { homeViewModel.clearSearchResults() } label: { Image(systemName: "xmark.circle.fill") }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))

                // Results/Status Area - Use computed properties
                Group {
                    if homeViewModel.isSearching {
                        loadingView // Use extracted view
                    } else if let errorMsg = homeViewModel.searchErrorMessage {
                        errorView(message: errorMsg) // Use extracted view
                    } else if !homeViewModel.searchResults.isEmpty {
                        searchResultsList // Use extracted view
                    } else {
                        promptView // Use extracted view
                    }
                }
                // Add animation for content changes if desired
                // .animation(.default, value: homeViewModel.isSearching)
                // .animation(.default, value: homeViewModel.searchErrorMessage)
                // .animation(.default, value: homeViewModel.searchResults)
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Extracted Subviews for Clarity

    private var loadingView: some View {
        VStack {
            ProgressView("Searching...")
                .padding()
            Spacer()
        }
    }

    private func errorView(message: String) -> some View {
        VStack {
            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
    }

    // Corrected version of the search results list
    private var searchResultsList: some View {
        List(homeViewModel.searchResults) { result in
            Button {
                homeViewModel.addLocation(from: result)
                dismiss()
            } label: {
                VStack(alignment: .leading) {
                    Text(result.name).font(.headline)
                    // --- CORRECTED ACCESS TO displayString ---
                    // Use the extension directly on 'result'
                    // Also, remove the replacement part unless truly needed
                    Text(result.displayString)
                         .font(.caption).foregroundColor(.gray)
                    // --- END CORRECTION ---
                }
            }
            .buttonStyle(.plain) // Keep text color default
        }
        .listStyle(.plain)
    }

    private var promptView: some View {
        VStack {
            Text("Enter a city name to search.")
                .foregroundColor(.secondary)
                .padding()
            Spacer()
        }
    }
}

// Ensure the GeocodeResponse extension exists correctly
extension GeocodeResponse {
     var displayString: String {
         var components = [name]
         if let state = state, !state.isEmpty { components.append(state) }
         components.append(country)
         return components.joined(separator: ", ")
     }
 }

#Preview {
     AddLocationView(homeViewModel: HomeViewModel())
}
