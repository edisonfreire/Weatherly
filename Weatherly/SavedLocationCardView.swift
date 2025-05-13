//
//  SavedLocationCardView.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import SwiftUI

struct SavedLocationCardView: View {
    let location: SavedLocation
    let weather: WeatherModel?
    let state: HomeViewModel.LocationCardState
    
    @AppStorage("temperatureUnit") private var displayUnit: TemperatureUnit = .celsius

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(location.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(location.displayString.replacingOccurrences(of: "\(location.name), ", with: ""))
                    .font(.callout)
                    .foregroundColor(.gray)
                    .lineLimit(1)

                // Add animation for state changes
                // .animation(.easeInOut, value: state)
            }

            Spacer() // Pushes weather info to the right

            // Content based on state
            Group {
                switch state {
                case .idle:
                    Image(systemName: "arrow.clockwise.circle") // Indicate tappable/refreshable
                        .foregroundColor(.gray)
                        .font(.title)
                case .loading:
                    ProgressView()
                        .frame(width: 40, height: 40) // Give it some size
                case .error:
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .font(.title)
                case .loaded:
                    if let current = weather?.current, let condition = current.weather.first {
                        HStack(spacing: 10) {
                            // Weather Condition Icon (Placeholder - Implement later)
                             WeatherIconView(iconCode: condition.icon)
                                .frame(width: 40, height: 40)
                            
                            let tempToDisplay = current.temp.asDisplayTemperature(in: displayUnit)
                            
                            Text("\(Int(tempToDisplay.rounded()))\(displayUnit.symbol)")
                                                             .font(.system(size: 34, weight: .light))
                        }
                    } else {
                        Image(systemName: "questionmark.diamond") // Data missing state
                            .foregroundColor(.orange)
                            .font(.title)
                    }
                }
            }
            // Add animation based on state value changing
             .animation(.default, value: state)

        }
        .padding(.vertical, 10)
        .contentShape(Rectangle()) // Make sure the whole HStack contributes to hit testing
    }
}

// --- Add Preview for SavedLocationCardView ---
#Preview {
    Group {
        SavedLocationCardView(location: SavedLocation(name: "London", state: nil, country: "GB", lat: 51.5, lon: -0.1), weather: nil, state: .idle)
        SavedLocationCardView(location: SavedLocation(name: "New York", state: "NY", country: "US", lat: 40.7, lon: -74.0), weather: nil, state: .loading)
        // Add loaded and error previews later
    }
    .padding()
    .background(Color(.systemBackground))
}
