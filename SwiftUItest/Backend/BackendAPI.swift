//
//  BackendAPI.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/5/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation
import Combine


class BackendAPI {
    //private var cancellable: AnyCancellable?
    
    private let session: URLSession
    
    init(session: URLSession = .shared) //The shared singleton session object. For basic requests, the URLSession class provides a shared singleton session object that gives you a reasonable default behavior for creating tasks.
    {
        self.session = session
        //testJson()
        //backend_secureGET(withDeviceID: "webnew2", type: "web")
        //backend_POST(withDeviceID: "webios2", type: "web")
    }
    
    func testJson()
    {
        //response data: //{"message":{"headerdata":"Sunday","time":"2020-04-06T20:04:15.638Z","deviceID":"webnew4","thingType":"web","sensorData":{"temperature":"30","batteryVoltage":"3300mV"}},"currenttime":"2020-04-07T05:38:19.620Z"}
        let json = """
        {
            "message": {\"headerdata\":\"Sunday\",\"time\":\"2020-04-06T20:04:15.638Z\",\"deviceID\":\"webnew4\",\"thingType\":\"web\", \"sensorData\":         {\"temperature\":\"30\",\"batteryVoltage\":\"3300mV\"} },
            "currenttime": "2020"
        }
        """.data(using: .utf8)!
        
        let newsensordata = SensorData(temperature: "30", batteryVoltage: "3300mV")
        
        do {
            let jsonsensorData = try JSONEncoder().encode(newsensordata)
            print(jsonsensorData.base64EncodedString())
            
            let decoder = JSONDecoder()
            let product1 = try decoder.decode(BackendResponse.self, from: json)//json
            print(product1.currenttime)
            print(product1.message.deviceID)
            print(product1.message.sensorData)
            
            let product2 = try decoder.decode(SensorData.self, from: jsonsensorData)
            print(product2.temperature)
            
            
        }
        catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func backend_GET(withDeviceID deviceID: String, type: String)
    {
        let backendURL = makeBackendAccessURLComponents(withDeviceID: deviceID, type: type).url!
        print(backendURL.absoluteString)
        
        let task = self.session.dataTask(with: backendURL) { data, response, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                fatalError("Error: invalid HTTP response code")
            }
            guard let data = data else {
                fatalError("Error: missing response data")
            }
            
            do {
                //let res = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]
                //print(res["message"])
                let decoder = JSONDecoder()
                let posts = try decoder.decode(BackendResponse.self, from: data)
                //self.results = posts
                print("DeviceID: \(posts.message.deviceID) Temperature: \(posts.message.sensorData.temperature)")
            }
            catch {
                print("Error: \(error.localizedDescription)")
            }
            
        }
        task.resume()
    }
    
    func backend_secureGET(withDeviceID deviceID: String, type: String)
    {
        //curl -v -X GET 'https://fllx1zdjx4.execute-api.us-west-2.amazonaws.com/default/JSHTTPBackend?deviceID=webnew2&thingType=web' -H 'content-type: application/json'  -H 'headerdata: Sunday' -H 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjU1NXZOMWxiNnNVckxtbU9JZ2VRTiJ9.eyJpc3MiOiJodHRwczovL3Nqc3VjbXBlLmF1dGgwLmNvbS8iLCJzdWIiOiI1aG1jMFdYcUNlMExCUEJxbU9tRERySzJQN3VNOU1kdUBjbGllbnRzIiwiYXVkIjoiaHR0cHM6Ly9hd3NhcGkuc2pzdWNtcGUiLCJpYXQiOjE1ODYyOTY2NzQsImV4cCI6MTU4NjM4MzA3NCwiYXpwIjoiNWhtYzBXWHFDZTBMQlBCcW1PbUREcksyUDd1TTlNZHUiLCJndHkiOiJjbGllbnQtY3JlZGVudGlhbHMifQ.JQY5qtfOX9wgpb4MluZ-4tqWFNniU8QzEBEOqTNAPk5n_E9f5G2RzIJ914kJ1EFJ9Hczka2Qh1olyVezpKDFndgY2SJX7ts7T1rkTeQN1fsu4xFUcHjlJBzgruJzlqLFxqysLAGtAb4Lk3NeAjvDZ0T8dtGQ-0nv2oOjNF0r8PQ08GHnPrXTIOFI0MuP7h5uVCs4tkRyW9G3np0OgTypKdmeR8VRgswcpU7Xo8tDve4NJBO8p4gxL9JTOWsdq8YVMXHrT8gEaGH9qANq_964AXZs80QVd2Zfsrr_4BIrLBfQtT2mpmXp_JOVHqZMI45J5uoff_vuNmt_Rdld1LvSAQ'
        
        let backendURL = makeBackendSecureAccessURLComponents(withDeviceID: deviceID, type: type).url!
        print(backendURL.absoluteString)
        var request = URLRequest(url: backendURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Sunday", forHTTPHeaderField: "headerdata")
        request.setValue("Bearer \(jwttoken)", forHTTPHeaderField: "Authorization")
        
        let task = self.session.dataTask(with: request) { data, response, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                fatalError("Error: invalid HTTP response code")
            }
            guard let data = data else {
                fatalError("Error: missing response data")
            }
            
            do {
                //let res = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]
                //print(res["message"])
                let decoder = JSONDecoder()
                let posts = try decoder.decode(BackendResponse.self, from: data)
                //self.results = posts
                print("DeviceID: \(posts.message.deviceID) Temperature: \(posts.message.sensorData.temperature)")
            }
            catch {
                print("Error: \(error.localizedDescription)")
            }
            
        }
        task.resume()
    }
    
    func backend_POST(withDeviceID deviceID: String, type: String)
    {
        //ref: https://developer.apple.com/documentation/foundation/url_loading_system/uploading_data_to_a_website
        //let url = URL(string: "https://example.com/post")!
        let backendURL = makeBackendAccessURLComponents(withDeviceID: deviceID, type: type).url!
        print(backendURL.absoluteString)
        var request = URLRequest(url: backendURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Sunday", forHTTPHeaderField: "headerdata")
        
        do {
            //Option1: create sensor data json
            let newsensordata = SensorData(temperature: "30", batteryVoltage: "3300mV")
            let jsonData = try JSONEncoder().encode(newsensordata)
        
            //Option2
//            let json = [
//                "temperature": "42",
//                "batteryVoltage": "3000mv"
//            ]
//            let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
            
            let task = self.session.uploadTask(with: request, from: jsonData) { data, response, error in
                if let error = error {
                    print ("error: \(error)")
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                    print ("server error")
                    return
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print ("got data: \(dataString)")
                }
            }
            task.resume()
        }catch {
            print("Error: \(error.localizedDescription)")
        }

    }
    
    func getPubData() -> AnyPublisher<Data, Error> {
        guard let request = buildRequest() else {
            return Fail(error: BackendAPIErrors.invalidURL).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: request)
//            .mapError({ error -> Error in
//                BackendResponseErrors(rawValue: error.code.rawValue) ?? BackendAPIErrors.unknownError
//            })
            .tryMap() { element -> Data in
            guard let httpResponse = element.response as? HTTPURLResponse,
                httpResponse.statusCode == 201 else {
                    throw URLError(.badServerResponse)
                }
            return element.data
            }
            //.map { $0.data } //Extract the Data object from response.
            .eraseToAnyPublisher()
    }
    
    func firebasegetPubData(queryid: String) -> AnyPublisher<Data, Error> {
        guard let request = firebasebuildRequest(queryid: queryid) else {
                return Fail(error: BackendAPIErrors.invalidURL).eraseToAnyPublisher()
            }
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 201 else {
                        throw URLError(.badServerResponse)
                    }
                return element.data
                }
                //.map { $0.data } //Extract the Data object from response.
                .eraseToAnyPublisher()
        }
    
    private func firebasebuildRequest(queryid: String) -> URLRequest? {
        let url = URL(string: "https://us-central1-cmpe277firebase.cloudfunctions.net/backendAPI?id=test04")!
        print(url.absoluteString)
        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData,
        timeoutInterval: 30)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Sunday", forHTTPHeaderField: "headerdata")
        //request.setValue("Bearer \(jwttoken)", forHTTPHeaderField: "Authorization")

        return request
    }
    
    private func buildRequest() -> URLRequest? {
        var components = URLComponents()
        components.scheme = BackendAPIURL.scheme
        components.host = BackendAPIURL.host
        components.path = BackendAPIURL.path//
        
        components.queryItems = [
            URLQueryItem(name: "deviceID", value: "webnew2"),
            URLQueryItem(name: "thingType", value: "web")
        ]

        guard let url = components.url else {
            return nil
        }
        print(url.absoluteString)
        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData,
        timeoutInterval: 30)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Sunday", forHTTPHeaderField: "headerdata")
        //request.setValue("Bearer \(jwttoken)", forHTTPHeaderField: "Authorization")

        return request
    }
    
    func makeBackendAccessURLComponents(
        withDeviceID deviceID: String, type: String
    ) -> URLComponents {
        var components = URLComponents()
        components.scheme = BackendAPIURL.scheme
        components.host = BackendAPIURL.host
        components.path = BackendAPIURL.path// + "/forecast"
        
        components.queryItems = [
            URLQueryItem(name: "deviceID", value: deviceID),
            URLQueryItem(name: "thingType", value: type)
            //URLQueryItem(name: "units", value: "metric"),
            //URLQueryItem(name: "APPID", value: BackendAPIURL.key)
        ]
        
        return components
    }

    func makeBackendSecureAccessURLComponents(
        withDeviceID deviceID: String, type: String
    ) -> URLComponents {
        var components = URLComponents()
        components.scheme = BackendAPIURL.scheme
        components.host = BackendAPIURL.host//"fllx1zdjx4.execute-api.us-west-2.amazonaws.com"//
        components.path = BackendAPIURL.path// + "/forecast"
        
        components.queryItems = [
            URLQueryItem(name: "deviceID", value: deviceID),
            URLQueryItem(name: "thingType", value: type)
            //URLQueryItem(name: "units", value: "metric"),
            //URLQueryItem(name: "APPID", value: BackendAPIURL.key)
        ]
        
        return components
    }
}



