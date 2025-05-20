//
//  WeatherFetchingService.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import Foundation
import Combine

protocol WeatherFetchingService {
    // For adding locations
    func searchCities(for city: String) -> AnyPublisher<[GeocodeResponse], Error>

    // For fetching weather for saved locations / forecasts
    func fetchWeatherByCoordinates(lat: Double, lon: Double) -> AnyPublisher<WeatherModel, Error>

}
