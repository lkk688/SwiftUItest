//
//  WeeklyWeatherViewModel.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 3/19/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

//import Foundation
import SwiftUI
import Combine

//conform to ObservableObject and Identifiable, used as bindings
class WeeklyWeatherViewModel: ObservableObject, Identifiable {
       
    // properly delegate @Published modifier makes it possible to observe the city property
    @Published var city: String = ""//London, UK
    
    // View’s data source in the ViewModel
    @Published var dataSource: [DailyWeatherRowViewModel] = []
    
    @Published var activityshouldAnimate = false//false
    
    @ObservedObject var locationViewModel = LocationViewModel()
    
    private let weatherFetcher: WeatherFetchable //DataFetcher
    
    // disposables as a collection of references to requests. Without keeping these references, the network requests you’ll make won’t be kept alive, preventing you from getting responses from the server.
    private var disposables = Set<AnyCancellable>()
    
    //Option1
//    init(weatherFetcher: WeatherFetchable) {
//        self.weatherFetcher = weatherFetcher
//        fetchWeather(forCity:city)//"London, UK"
//    }
    
    //Option2
    init(
        weatherFetcher: WeatherFetchable,
        scheduler: DispatchQueue = DispatchQueue(label: "WeatherViewModel")
        //specify which queue the HTTP request will use.
    ) {
        self.weatherFetcher = weatherFetcher
        $city
            .dropFirst(1) //As soon as you create the observation, $city emits its first value. Since the first value is an empty string, you need to skip it to avoid an unintended network call.
            .debounce(for: .seconds(1), scheduler: scheduler) //debounce works by waiting a second until the user stops typing
            .removeDuplicates()
            .filter{ $0.count >= 1 }
            .sink(receiveValue: fetchWeather(forCity:)) //You observe these events via sink(receiveValue:) and handle them with fetchWeather(forCity:)
            .store(in: &disposables)
    }
    
    func displayWeatherInfo() -> String {
        var str: String = ""
        if dataSource.isEmpty
        {
            str = "Data Empty"
        } else {
            str = "Temperature \(dataSource[0].temperature)°C Full info:  \(dataSource[0].fullDescription)% ."
        }
        return str
    }
    
    func fetchWeather(forCity city: String) {
        //making a new request to fetch the information from the OpenWeatherMap API. Pass the city name as the argument.
        DispatchQueue.main.async {
            // update ui here
            self.activityshouldAnimate = true
        }
        
        //using the DataFetcher Class implementation
        weatherFetcher.weeklyWeatherForecast(forCity: city)
            .map { response in
                //Map the response (WeeklyForecastResponse object) to an array of DailyWeatherRowViewModel objects, a single row in the list
                response.list.map(DailyWeatherRowViewModel.init)
        }
        .map(Array.removeDuplicates) //API returns multiple temperatures for the same day depending on the time of the day, so remove the duplicates
        .receive(on: DispatchQueue.main) //updating the UI must happen on the main queue
        .sink( //Attaches a subscriber with closure-based behavior to a publisher that never fails. Takes two closures
            //update dataSource
            //The first closure executes when it receives Subscribers.Completion
            receiveCompletion: { [weak self] value in
                guard let self = self else { return }
                switch value {
                case .failure:
                    self.dataSource = []
                    self.activityshouldAnimate = false
                case .finished:
                    self.activityshouldAnimate = false
                    break
                }
            },
            //The second closure executes when it receives an element from the publisher.
            receiveValue: { [weak self] forecast in
                guard let self = self else { return }
                //Update dataSource when a new forecast arrives.
                self.dataSource = forecast
        })
            .store(in: &disposables) //add the cancellable reference to the disposables set, without keeping this reference alive, the network publisher will terminate immediately.
    }
}

/// Taken from here: https://stackoverflow.com/a/46354989/491239
public extension Array where Element: Hashable {
  static func removeDuplicates(_ elements: [Element]) -> [Element] {
    var seen = Set<Element>()
    return elements.filter{ seen.insert($0).inserted }
  }
}

//New added for current weather view
extension WeeklyWeatherViewModel {
    var currentWeatherView: some View {
        return WeeklyWeatherBuilder.makeCurrentWeatherView(
            withCity: city,
            weatherFetcher: weatherFetcher
        )
    }
}

enum WeeklyWeatherBuilder {
    static func makeCurrentWeatherView(
        withCity city: String,
        weatherFetcher: WeatherFetchable
    ) -> some View {
        let viewModel = CurrentWeatherViewModel(
            city: city,
            weatherFetcher: weatherFetcher)
        return CurrentWeatherView(viewModel: viewModel)
    }
}

//New added for current location weather view
extension WeeklyWeatherViewModel {
    var currentLocationWeatherView: some View {
        return WeeklyWeatherBuilder.makeCurrentWeatherView(
            withCity: locationViewModel.placemark?.locality ?? "San Jose",
            weatherFetcher: weatherFetcher
        )
    }
}
