//
//  CurrentDayDetailsView.swift
//  Weatherly
//
//  Created by Edison Freire on 5/6/25.
//

import SwiftUI

struct CurrentDayDetailsView: View {
    let current: WeatherModel.Current
    let locationName: String // For displaying the location name prominently
    @AppStorage("temperatureUnit") private var displayUnit: TemperatureUnit = .celsius
    
    // Helper to get primary weather condition
    private var condition: WeatherModel.WeatherCondition? {
        current.weather.first
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Current Weather in \(locationName)")
                .font(.title2).bold()
                .padding(.bottom, 5)
            
            HStack {
                WeatherIconView(iconCode: condition?.icon ?? "questionmark.diamond")
                    .font(.system(size: 60)) // Larger icon
                    .frame(width: 70, height: 70)
                
                VStack(alignment: .leading) {
                    let tempToDisplay = current.temp.asDisplayTemperature(in: displayUnit)
                    Text("\(Int(tempToDisplay.rounded()))\(displayUnit.symbol)")
                        .font(.system(size: 50, weight: .bold))
                    Text(condition?.description.capitalized ?? "No description")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            
            let filesLikeToDisplay = current.feelsLike.asDisplayTemperature(in: displayUnit)
            Text("Feels like \(Int(filesLikeToDisplay.rounded()))\(displayUnit.symbol)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Divider()
            
            // Grid for additional details
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                DetailItem(label: "Humidity", value: "\(current.humidity)%")
                DetailItem(label: "Pressure", value: "\(current.pressure) hPa")
                if let uvi = current.uvi {
                    DetailItem(label: "UV Index", value: String(format: "%.1f", uvi))
                }
                if let visibility = current.visibility {
                    DetailItem(label: "Visibility", value: "\(visibility / 1000) km")
                }
//                if let windSpeed = current.windSpeed {
//                    let windDisplayUnit = preferredUnitSystem == .fahrenheit ? "mph" : "m/s" // OpenWeather default units
//                    DetailItem(label: "Wind Speed", value: "\(String(format: "%.1f", windSpeed)) \(windDisplayUnit)")
//                }
                if let rainLastHour = current.rain?.oneHour {
                    // CORRECTED: Use String(format:)
                    DetailItem(label: "Rain (1h)", value: "\(String(format: "%.1f", rainLastHour)) mm")
                }
                if let snowLastHour = current.snow?.oneHour {
                    // CORRECTED: Use String(format:)
                    DetailItem(label: "Snow (1h)", value: "\(String(format: "%.1f", snowLastHour)) mm")
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    struct DetailItem: View {
        let label: String
        let value: String
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
    
#if DEBUG
    struct CurrentDayDetailsView_Previews: PreviewProvider {
        static var previews: some View {
            CurrentDayDetailsView(
                current: WeatherModel.Current(
                    dt: 1742317200,
                    temp: 25.0,
                    feelsLike: 26.0,
                    pressure: 1012,
                    humidity: 60,
                    uvi: 7.5,
                    visibility: 10000,
                    windSpeed: 5.5,
                    windDeg: 180,
                    weather: [WeatherModel.WeatherCondition(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
                    rain: WeatherModel.Rain(oneHour: 0.5),
                    snow: nil
                ),
                locationName: "Cupertino"
            )
            .padding()
        }
    }
#endif
}
