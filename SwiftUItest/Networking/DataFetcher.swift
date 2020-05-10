//
//  DataFetcher.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 3/19/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation
import Combine


class DataFetcher {
    
    private var cancellable: AnyCancellable?
    
    private let session: URLSession
    
    init(session: URLSession = .shared) //The shared singleton session object. For basic requests, the URLSession class provides a shared singleton session object that gives you a reasonable default behavior for creating tasks.
    {
        self.session = session
    }
    
    func getWeather()
    {
        //        let apikey = OpenWeatherAPI.key
        let city = "Atlanta,us"
        //let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apikey)")!
        //let weatherURL = URL(string:"https://api.openweathermap.org/data/2.5/weather?id=524901&APPID=2b492c001d57cd5499947bd3d3f9c47b")!
        let weatherURL = makeCurrentDayForecastComponents(withCity: city).url!
        //First way
        //        self.session.dataTask(with: weatherURL) { data, response, error in
        //            if let error = error {
        //                print("Error:\n\(error)")
        //                fatalError("Error: \(error.localizedDescription)")
        //            } else {
        //                do {
        //                    let weather = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
        //                    print("Temperature \(weather["main"]!["temp"]!!)°C Humidity \(weather["main"]!["humidity"]!!)% Pressure \(weather["main"]!["pressure"]!!)hPa.")
        //                } catch let jsonError as NSError {
        //                    print("JSON error:\n\(jsonError.description)")
        //                }
        //            }
        //        }.resume()
        
        //Second way
        let task = self.session.dataTask(with: weatherURL) { data, response, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                fatalError("Error: invalid HTTP response code")
            }
            guard let data = data else {
                fatalError("Error: missing response data")
            }
            
            do {
                let decoder = JSONDecoder()
                let posts = try decoder.decode(CurrentWeatherForecastResponse.self, from: data)
                print("Temperature \(posts.main.temperature)°C Humidity \(posts.main.humidity)% .")
            }
            catch {
                print("Error: \(error.localizedDescription)")
            }
            
        }
        task.resume()
    }
}

protocol WeatherFetchable {
    func weeklyWeatherForecast(
        forCity city: String
    ) -> AnyPublisher<WeeklyForecastResponse, WeatherError>
    //display the weather forecast for the next five days
    //The first parameter (WeeklyForecastResponse) refers to the type it returns if the computation is successful
    //the second refers to the type if it fails (WeatherError).
    
    func currentWeatherForecast(
        forCity city: String
    ) -> AnyPublisher<CurrentWeatherForecastResponse, WeatherError>
    //view more detailed weather information
}

extension DataFetcher: WeatherFetchable {
    //implement the protocol method
    func weeklyWeatherForecast(
        forCity city: String
    ) -> AnyPublisher<WeeklyForecastResponse, WeatherError> {
        return forecast(with: makeWeeklyForecastComponents(withCity: city))
    }
    
    func currentWeatherForecast(
        forCity city: String
    ) -> AnyPublisher<CurrentWeatherForecastResponse, WeatherError> {
        return forecast(with: makeCurrentDayForecastComponents(withCity: city))
    }
    
    private func forecast<T>(
        with components: URLComponents
    ) -> AnyPublisher<T, WeatherError> where T: Decodable //T here is a Decodable object and our goal is to take the data that’s returned by a network call and to decode tLhis data into a model of type T.
    {
        //create an instance of URL from the URLComponents.
        guard let url = components.url else {
            //the method returns AnyPublisher<T, WeatherError>, you map the error from URLError to WeatherError.
            let error = WeatherError.network(description: "Couldn't create URL")
            return Fail(error: error).eraseToAnyPublisher()
            //Fail publisher that immediately terminates with the specified failure.
            //If this fails, return an error wrapped in a Fail value. Then, erase its type to AnyPublisher, since that’s the method’s return type.
        }
        
        //returns a publisher so that other objects can subscribe to this publisher, and can handle the result of the network call
            //Uses the new URLSession method dataTaskPublisher(for:) to fetch the data, takes an instance of URLRequest and returns either a tuple (Data, URLResponse) or a URLError
        print(url.absoluteString)
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error in
                .network(description: error.localizedDescription)
        }
        .flatMap(maxPublishers: .max(1)) { pair in
            //decode(type:decoder:) can only be used on publishers that have an Output of Data. To do this, we can map the output of the data task publisher and feed the result of this map operation to the decode operation:
            decode(pair.data)
            //takes the Output of the URLSession.DataTaskPublisher which is (data: Data, response: URLResponse) and transforms that into a publisher whose Output is Data using the map operator.
        }
        .eraseToAnyPublisher()
        //In order to hide the details of our publisher chain, and to make the return type more readable we must convert our publisher chain to a publisher of type AnyPublisher. We can do this by using the eraseToAnyPublisher after the decode(type:decoder:) operator.
    }
}

//decode: utility method to convert the data into a decoded object
func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, WeatherError> {
    let decoder = JSONDecoder()//This uses a standard JSONDecoder to decode the JSON from the OpenWeatherMap API.
    decoder.dateDecodingStrategy = .secondsSince1970
    
    //struct Just<Output>: A publisher that emits an output to each subscriber just once, and then finishes.
    //ref: https://developer.apple.com/documentation/combine/just
    //Just publisher completes immediately with the supplied value, it can never produce an error, and it’s a valid publisher to use in the catch operator
    return Just(data)
        .decode(type: T.self, decoder: decoder)
        .mapError { error in
            .parsing(description: error.localizedDescription) }
    .eraseToAnyPublisher()
    //we need to use eraseToAnyPublisher() to transform the result of the catch operator to AnyPublisher to avoid having to write Publishers.Catch<AnyPublisher<PhotoFeed, Error>, Publisher> as our return type.
}


private extension DataFetcher {
    struct OpenWeatherAPI {
        static let scheme = "https"
        static let host = "api.openweathermap.org"
        static let path = "/data/2.5"
        static let key = "2b492c001d57cd5499947bd3d3f9c47b"//<your key>"
    }
    
    func makeWeeklyForecastComponents(
        withCity city: String
    ) -> URLComponents {
        var components = URLComponents()
        components.scheme = OpenWeatherAPI.scheme
        components.host = OpenWeatherAPI.host
        components.path = OpenWeatherAPI.path + "/forecast"
        
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "mode", value: "json"),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "APPID", value: OpenWeatherAPI.key)
        ]
        
        return components
    }
    
    func makeCurrentDayForecastComponents(
        withCity city: String
    ) -> URLComponents {
        var components = URLComponents()
        components.scheme = OpenWeatherAPI.scheme
        components.host = OpenWeatherAPI.host
        components.path = OpenWeatherAPI.path + "/weather"
        
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "mode", value: "json"),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "APPID", value: OpenWeatherAPI.key)
        ]
        
        return components
    }
}

struct WeeklyForecastResponse: Codable {
    let list: [Item]
    
    struct Item: Codable {
        let date: Date
        let main: MainClass
        let weather: [Weather]
        
        enum CodingKeys: String, CodingKey {
            case date = "dt"
            case main
            case weather
        }
    }
    
    struct MainClass: Codable {
        let temp: Double
    }
    
    struct Weather: Codable {
        let main: MainEnum
        let weatherDescription: String
        
        enum CodingKeys: String, CodingKey {
            case main
            case weatherDescription = "description"
        }
    }
    
    enum MainEnum: String, Codable {
        case clear = "Clear"
        case clouds = "Clouds"
        case rain = "Rain"
    }
    
}

//{"coord":{"lon":37.62,"lat":55.75},"weather":[{"id":800,"main":"Clear","description":"clear sky","icon":"01d"}],"base":"stations","main":{"temp":272.75,"feels_like":269.5,"temp_min":271.15,"temp_max":274.82,"pressure":1036,"humidity":74},"visibility":10000,"wind":{"speed":1},"clouds":{"all":2},"dt":1586236291,"sys":{"type":1,"id":9029,"country":"RU","sunrise":1586227438,"sunset":1586276325},"timezone":10800,"id":524901,"name":"Moscow","cod":200}
struct CurrentWeatherForecastResponse: Decodable {
    let coord: Coord
    let main: Main
    
    struct Main: Codable {
        let temperature: Double
        let humidity: Int
        let maxTemperature: Double
        let minTemperature: Double
        
        enum CodingKeys: String, CodingKey {
            case temperature = "temp"
            case humidity
            case maxTemperature = "temp_max"
            case minTemperature = "temp_min"
        }
    }
    
    struct Coord: Codable {
        let lon: Double
        let lat: Double
    }
}

enum WeatherError: Error {
    case parsing(description: String)
    case network(description: String)
}


