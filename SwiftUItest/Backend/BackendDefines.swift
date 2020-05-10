//
//  BackendURLs.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/9/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation

//private var results: BackendResponse
let jwttoken = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjU1NXZOMWxiNnNVckxtbU9JZ2VRTiJ9.eyJpc3MiOiJodHRwczovL3Nqc3VjbXBlLmF1dGgwLmNvbS8iLCJzdWIiOiI1aG1jMFdYcUNlMExCUEJxbU9tRERySzJQN3VNOU1kdUBjbGllbnRzIiwiYXVkIjoiaHR0cHM6Ly9hd3NhcGkuc2pzdWNtcGUiLCJpYXQiOjE1ODYyOTY2NzQsImV4cCI6MTU4NjM4MzA3NCwiYXpwIjoiNWhtYzBXWHFDZTBMQlBCcW1PbUREcksyUDd1TTlNZHUiLCJndHkiOiJjbGllbnQtY3JlZGVudGlhbHMifQ.JQY5qtfOX9wgpb4MluZ-4tqWFNniU8QzEBEOqTNAPk5n_E9f5G2RzIJ914kJ1EFJ9Hczka2Qh1olyVezpKDFndgY2SJX7ts7T1rkTeQN1fsu4xFUcHjlJBzgruJzlqLFxqysLAGtAb4Lk3NeAjvDZ0T8dtGQ-0nv2oOjNF0r8PQ08GHnPrXTIOFI0MuP7h5uVCs4tkRyW9G3np0OgTypKdmeR8VRgswcpU7Xo8tDve4NJBO8p4gxL9JTOWsdq8YVMXHrT8gEaGH9qANq_964AXZs80QVd2Zfsrr_4BIrLBfQtT2mpmXp_JOVHqZMI45J5uoff_vuNmt_Rdld1LvSAQ"

struct BackendAPIURL {

    //curl -v -X POST 'https://us-central1-cmpe277firebase.cloudfunctions.net/sendtoTopic'  -H 'content-type: application/json'  -H 'headerdata: Sunday'  -d  '{ "sensorData" : 40 }'
    static let scheme = "https"
    static let host = "us-central1-cmpe277firebase.cloudfunctions.net"
    static let path = "backendAPI"
}

protocol EndpointProtocol {
    var locale: String { get }
    
    var region: String { get }
    
    var baseURL: String { get }
    
    var absoluteURL: String { get }
    
    var params: [String: String] { get }
    
    var headers: [String: String] { get }
}

extension EndpointProtocol {
    var locale: String {
        return Locale.current.languageCode ?? "en"
    }
    
    var region: String {
        return Locale.current.regionCode ?? "us"
    }
}

enum NewsEndpoint: EndpointProtocol {
    case getTopHeadlines
    case getArticlesFromCategory(_ category: String)
    case getSources
    case getArticlesFromSource(_ source: String)
    case searchForArticles(searchFilter: String)
    
    var baseURL: String {
        return "https://newsapi.org/v2"
    }
    
    var absoluteURL: String {
        switch self {
        case .getTopHeadlines, .getArticlesFromCategory:
            return baseURL + "/top-headlines"
            
        case .getSources:
            return baseURL + "/sources"
            
        case .getArticlesFromSource, .searchForArticles:
            return baseURL + "/everything"
        }
    }
    
    var params: [String: String] {
        switch self {
        case .getTopHeadlines:
            return ["country": region]
            
        case let .getArticlesFromCategory(category):
            return ["country": region, "category": category]
            
        case .getSources:
            return ["language": locale, "country": region]
            
        case let .getArticlesFromSource(source):
            return ["sources": source, "language": locale]
            
        case let .searchForArticles(searchFilter):
            return ["q": searchFilter, "language": locale]
        }
    }
    
    var headers: [String: String] {
        return [
            "X-Api-Key": "404fcb2608764b3983f73c8a4119b20d", //apply the new api key
            "Content-type": "application/json",
            "Accept": "application/json"
        ]
    }
}

struct SensorData: Codable {
    let temperature: String
    let batteryVoltage: String
}
//{"message":{"headerdata":"Sunday","time":"2020-04-06T20:04:15.638Z","deviceID":"webnew4","thingType":"web","sensorData":{"temperature":"30","batteryVoltage":"3300mV"}},"currenttime":"2020-04-07T05:38:19.620Z"}
struct BackendResponse: Codable//Decodable//Codable the same?
{
    
    var message: Message
    var currenttime: String
    
    struct Message: Codable {
        let headerdata: String
        let time: String
        let deviceID: String
        let thingType: String
        let sensorData: SensorData

        enum CodingKeys: String, CodingKey {
            case headerdata = "headerdata"
            case time = "time"
            case deviceID = "deviceID"
            case thingType = "thingType"
            case sensorData = "sensorData"
        }
    }
}

struct FirebaseResponse: Codable//Decodable//Codable the same?
{
    var time: String
    var payload: Payload
    var name: String
    
    struct Payload: Codable {
        let sensor: String
        let value: String

        enum CodingKeys: String, CodingKey {
            case sensor = "sensor"
            case value = "value"
        }
    }
}


enum BackendAPIErrors: LocalizedError {
    case invalidURL
    case dataNil
    case decodingError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .dataNil:
            return "Empty data.".localized()
        case .decodingError:
            return "Data has invalid format.".localized()
        default:
            return "Network Error".localized()
        }
    }
}

enum BackendResponseErrors: Int, LocalizedError {
    case badRequest = 400
    case unAuthorized = 401
    case tooManyRequests = 429
    case serverError = 500
    
    var errorDescription: String? {
        switch self {
        case .tooManyRequests:
            return "You made too many requests within a window of time and have been rate limited. Back off for a while."//.localized()
        case .serverError:
            return "Server error."//.localized()
        default:
            return "Network Error".localized()
        }
    }
}

enum BackendError: Error {
    case parsing(description: String)
    case network(description: String)
}
