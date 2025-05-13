//
//  CitySearchInputView.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import SwiftUI

// NOTE: This View might not be directly used in the 'Saved Locations' HomeView anymore,
// but similar logic is now inside AddLocationView. Keep for reference or delete.
struct CitySearchInputView: View {
    @Binding var cityInput: String
    var onSearch: () -> Void
    var isDisabled: Bool
    var isLoading: Bool

    var body: some View {
        HStack {
            TextField("Enter city name", text: $cityInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit(onSearch) // Allow search on return key
                .disabled(isLoading)

            Button(action: onSearch) {
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "magnifyingglass")
                }
            }
            .disabled(isDisabled || isLoading)
            // .buttonStyle(.borderedProminent) // Optional styling
        }
        .padding(.horizontal)
    }
}
