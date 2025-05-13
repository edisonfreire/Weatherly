//
//  SearchResultsView.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import SwiftUI

// NOTE: This View is likely replaced by the List within AddLocationView.
// Keep for reference or delete.
struct SearchResultsView: View {
    let results: [GeocodeResponse]
    var onSelect: (GeocodeResponse) -> Void

    var body: some View {
        List(results) { location in
            Button {
                onSelect(location)
            } label: {
                VStack(alignment: .leading) {
                    Text(location.name).font(.headline)
                    Text(location.displayString.replacingOccurrences(of: "\(location.name), ", with: "")).font(.caption)
                }
            }
             .buttonStyle(.plain) // Use plain style for default text color
        }
        .navigationTitle(Constants.SearchResults.navigationTitle)
    }
}

// Add Preview if needed
