//
//  HourlyForecastView.swift
//  Weatherly
//
//  Created by Edison Freire on 5/6/25.
//

import SwiftUI

struct HourlyForecastView: View {
    let hourlyForecasts: [WeatherModel.HourlyForecast]
    let formatTime: (Int) -> String // Closure to format time, passed from ViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Hourly Forecast")
                .font(.title3).bold()
                .padding(.leading)
                .padding(.bottom, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(hourlyForecasts) { hourly in
                        HourlyCardView(
                            hourly: hourly,
                            timeString: formatTime(hourly.dt)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8) // Add some vertical padding for the cards
            }
        }
    }
}

struct HourlyCardView: View {
    let hourly: WeatherModel.HourlyForecast
    let timeString: String
    @AppStorage("temperatureUnit") private var displayUnit: TemperatureUnit = .celsius

    private var condition: WeatherModel.WeatherCondition? {
        hourly.weather.first
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(timeString)
                .font(.caption)
                .fontWeight(.medium)
            
            WeatherIconView(iconCode: condition?.icon ?? "questionmark.diamond")
                .frame(width: 30, height: 30)
            
            let hourlyTempToDisplay = hourly.temp.asDisplayTemperature(in: displayUnit)
            Text("\(Int(hourlyTempToDisplay .rounded()))\(displayUnit.symbol)")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            if let pop = hourly.pop, pop > 0.1 { // Show PoP if significant
                HStack(spacing: 2) {
                    Image(systemName: "umbrella.fill") // Or "cloud.rain.fill"
                        .foregroundColor(.blue)
                    Text("\(Int(pop * 100))%")
                }
                .font(.caption2)
            }
        }
        .padding(10)
        .background(Color(.tertiarySystemGroupedBackground)) // Slightly different background
        .cornerRadius(10)
    }
}

#if DEBUG
struct HourlyForecastView_Previews: PreviewProvider {
    static let sampleHourly: [WeatherModel.HourlyForecast] = [
        .init(dt: 1742317200, temp: 25, feelsLike: 26, pressure: 1012, humidity: 60, uvi: 7, clouds: 10, visibility: 10000, windSpeed: 5, windDeg: 180, windGust: 7, weather: [.init(id: 800, main: "Clear", description: "clear sky", icon: "01d")], pop: 0.1, rain: nil, snow: nil),
        .init(dt: 1742320800, temp: 24, feelsLike: 25, pressure: 1012, humidity: 62, uvi: 6, clouds: 20, visibility: 10000, windSpeed: 5.2, windDeg: 185, windGust: 7.5, weather: [.init(id: 801, main: "Clouds", description: "few clouds", icon: "02d")], pop: 0.2, rain: nil, snow: nil),
        .init(dt: 1742324400, temp: 22, feelsLike: 22, pressure: 1013, humidity: 65, uvi: 4, clouds: 50, visibility: 9000, windSpeed: 4.8, windDeg: 190, windGust: 6.5, weather: [.init(id: 802, main: "Clouds", description: "scattered clouds", icon: "03d")], pop: 0.0, rain: nil, snow: nil)
    ]
    static func formatTimePreview(timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }
    static var previews: some View {
        HourlyForecastView(hourlyForecasts: sampleHourly, formatTime: formatTimePreview)
            .padding()
            .background(Color.gray.opacity(0.1))
    }
}
#endif
