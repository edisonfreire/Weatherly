//
//  ForecastCardView.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import SwiftUI

struct ForecastCardView: View {
    let forecast: WeatherModel.DailyForecast
    let formattedDate: String
    @AppStorage("temperatureUnit") private var displayUnit: TemperatureUnit = .celsius
    

    private var condition: WeatherModel.WeatherCondition? {
        forecast.weather.first
    }

    var body: some View {
        HStack(spacing: 12) {
            WeatherIconView(iconCode: condition?.icon ?? "questionmark.diamond")
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.headline)
                    .lineLimit(1)

                Text(condition?.description.capitalized ?? forecast.summary ?? "No description")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                let tempToDisplayMax = forecast.temp.max.asDisplayTemperature(in: displayUnit)
                Text("\(Int(tempToDisplayMax.rounded()))\(displayUnit.symbol)")
                    .font(.headline)
                    .fontWeight(.medium)
                
                let tempToDisplayMin = forecast.temp.min.asDisplayTemperature(in: displayUnit)
                Text("\(Int(tempToDisplayMin.rounded()))\(displayUnit.symbol)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(width: 55, alignment: .trailing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

#Preview {
    ForecastCardView(
        forecast: WeatherModel.DailyForecast(
             dt: 1742317200, // Timestamp
             summary: "Partly cloudy with a chance of rain.", // String?
             temp: WeatherModel.Temperature( // Temperature
                day: 12.0,
                min: 5.2,
                max: 15.8,
                night: 7.0,    // Double?
                eve: 10.5,     // Double?
                morn: 6.1      // Double?
             ),
             feelsLike: WeatherModel.DailyFeelsLike( // DailyFeelsLike?
                day: 11.5,
                night: 6.0,
                eve: 9.5,
                morn: 5.0
             ),
             pressure: 1012,      // Int
             humidity: 75,        // Int
             dewPoint: 8.0,       // Double?
             windSpeed: 15.0,     // Double?
             windDeg: 180,        // Int?
             windGust: 25.0,      // Double?
             weather: [           // [WeatherCondition]
                .init(id: 802, main: "Clouds", description: "scattered clouds", icon: "03d")
             ],
             clouds: 60,          // Int?
             pop: 0.4,            // Double? (Probability of precipitation)
             uvi: 5.5,            // Double?
             rain: 2.5,           // Double? (Rain volume)
             snow: nil            // Double? (Snow volume)
         ),
         formattedDate: "Tuesday, Mar 19" // Example formatted date
    )
    .padding()
    .background(Color.blue.opacity(0.1))
}
