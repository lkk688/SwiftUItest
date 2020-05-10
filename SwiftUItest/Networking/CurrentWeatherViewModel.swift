//
//  CurrentWeatherViewModel.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 3/20/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

//import Foundation
import SwiftUI
import Combine
import MapKit //for CLLocationCoordinate2D

class CurrentWeatherViewModel: ObservableObject, Identifiable {
    // Expose an optional CurrentWeatherRowViewModel as the data source
    @Published var dataSource: CurrentWeatherRowViewModel?
    
    let city: String
    private let weatherFetcher: WeatherFetchable
    private var disposables = Set<AnyCancellable>()
    
    init(city: String, weatherFetcher: WeatherFetchable) {
        self.weatherFetcher = weatherFetcher
        self.city = city
    }
    
    func refresh() {
        weatherFetcher
            .currentWeatherForecast(forCity: city)
            //Transform new values to a CurrentWeatherRowViewModel as they come in the form of a CurrentWeatherForecastResponse format
            .map(CurrentWeatherRowViewModel.init)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let self = self else { return }
                switch value {
                case .failure:
                    self.dataSource = nil
                case .finished:
                    break
                }
                }, receiveValue: { [weak self] weather in
                    guard let self = self else { return }
                    self.dataSource = weather
            })
            .store(in: &disposables)
    }
}


struct CurrentWeatherRowViewModel {
  private let item: CurrentWeatherForecastResponse
  
  var temperature: String {
    return String(format: "%.1f", item.main.temperature)
  }
  
  var maxTemperature: String {
    return String(format: "%.1f", item.main.maxTemperature)
  }
  
  var minTemperature: String {
    return String(format: "%.1f", item.main.minTemperature)
  }
  
  var humidity: String {
    return String(format: "%.1f", item.main.humidity)
  }
  
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D.init(latitude: item.coord.lat, longitude: item.coord.lon)
  }
  
  init(item: CurrentWeatherForecastResponse) {
    self.item = item
  }
}
