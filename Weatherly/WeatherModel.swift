//
//  WeatherModel.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import Foundation

struct WeatherModel: Codable, Equatable {
    let lat: Double?  // Add lat/lon to potentially verify response matches request
    let lon: Double?
    let current: Current
    let hourly: [HourlyForecast]?
    let daily: [DailyForecast]

    struct Current: Codable, Equatable {
        let dt: Int
        let temp: Double
        let feelsLike: Double
        let pressure: Int
        let humidity: Int
        let uvi: Double?
        let visibility: Int?
        let windSpeed: Double?
        let windDeg: Int?
        let weather: [WeatherCondition]
        let rain: Rain?
        let snow: Snow?
    }

    struct HourlyForecast: Codable, Identifiable, Equatable {
        var id: Int { dt }
        let dt: Int
        let temp: Double
        let feelsLike: Double
        let pressure: Int
        let humidity: Int
        let uvi: Double?
        let clouds: Int
        let visibility: Int?
        let windSpeed: Double
        let windDeg: Int
        let windGust: Double?
        let weather: [WeatherCondition]
        let pop: Double?  // Probability of precipitation
        let rain: Rain?  // Rain volume for the last hour
        let snow: Snow?  // Snow volume for the last hour

        static func == (lhs: HourlyForecast, rhs: HourlyForecast) -> Bool {
            lhs.dt == rhs.dt
        }
    }

    struct WeatherCondition: Codable, Equatable, Hashable {  // Added Hashable
        let id: Int
        let main: String
        let description: String
        let icon: String
    }

    struct DailyForecast: Codable, Identifiable, Equatable {
        var id: Int { dt }
        let dt: Int
        let summary: String?
        let temp: Temperature
        let feelsLike: DailyFeelsLike?  // ADDED: Feels like for different times of day
        let pressure: Int
        let humidity: Int
        let dewPoint: Double?
        let windSpeed: Double?
        let windDeg: Int?
        let windGust: Double?
        let weather: [WeatherCondition]
        let clouds: Int?
        let pop: Double?  // Probability of precipitation
        let uvi: Double?
        let rain: Double?  // Rain volume
        let snow: Double?  // Snow volume
    }

    struct Temperature: Codable, Equatable {
        let day: Double
        let min: Double
        let max: Double
        let night: Double?  // ADDED
        let eve: Double?  // ADDED
        let morn: Double?  // ADDED
    }

    struct DailyFeelsLike: Codable, Equatable {
        let day: Double?
        let night: Double?
        let eve: Double?
        let morn: Double?
    }

    struct Rain: Codable, Equatable {
        let oneHour: Double?  // Using "oneHour" to match "1h" key if it comes like that

        // If the key is literally "1h", you need a custom CodingKey
        private enum CodingKeys: String, CodingKey {
            case oneHour = "1h"
        }
    }

    // ADDED: Struct for snow volume (used in current, hourly, daily)
    struct Snow: Codable, Equatable {
        let oneHour: Double?  // Using "oneHour" to match "1h" key

        private enum CodingKeys: String, CodingKey {
            case oneHour = "1h"
        }
    }

    static func == (lhs: WeatherModel, rhs: WeatherModel) -> Bool {
        lhs.current == rhs.current && lhs.daily == rhs.daily
            && lhs.hourly == rhs.hourly
    }
}
