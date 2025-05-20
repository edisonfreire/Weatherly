//
//  WeatherAPIService.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import Foundation
import Combine

class WeatherAPIService: WeatherFetchingService {
    private let baseURLString = "https://api.openweathermap.org"
    private let apiKey = Secrets.apiKey
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase // Use strategy
        return decoder
    }()

    // For adding locations
    func searchCities(for city: String) -> AnyPublisher<[GeocodeResponse], Error> {
        guard var components = URLComponents(string: baseURLString) else {
            return Fail(error: URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Invalid base URL string."]))
                .eraseToAnyPublisher()
        }
        components.path = "/geo/1.0/direct"
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "limit", value: "10"), // Limit results
            URLQueryItem(name: "appid", value: apiKey)
        ]

        guard let url = components.url else {
            return Fail(error: URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Could not create Geo URL from components."]))
                .eraseToAnyPublisher()
        }

        #if DEBUG
        print("➡️ Requesting Geo URL: \(url)")
        #endif

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [GeocodeResponse].self, decoder: decoder) // Use configured decoder
            .mapError { error -> Error in // Map decoding errors for clarity
                print("🔴 Geo Decoding Error: \(error)")
                return error
            }
            .eraseToAnyPublisher()
    }

    // For fetching weather for saved locations / forecasts
    func fetchWeatherByCoordinates(lat: Double, lon: Double) -> AnyPublisher<WeatherModel, Error> {
        guard var components = URLComponents(string: baseURLString) else {
            return Fail(error: URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Invalid base URL string."]))
               .eraseToAnyPublisher()
        }
        // Using One Call API 3.0
        components.path = "/data/3.0/onecall"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "exclude", value: "minutely,alerts"), // Exclude data we don't need yet
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]

        guard let url = components.url else {
            return Fail(error: URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Could not create Weather URL from components."]))
                .eraseToAnyPublisher()
        }

        #if DEBUG
        print("➡️ Requesting Weather URL: \(url)")
        #endif

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherModel.self, decoder: decoder) // Use configured decoder
             .mapError { error -> Error in // Map decoding errors for clarity
                 print("🔴 Weather Decoding Error: \(error)")
                 return error
             }
            .eraseToAnyPublisher()
    }
}
