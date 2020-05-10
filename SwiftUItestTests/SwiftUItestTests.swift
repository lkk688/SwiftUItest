//
//  SwiftUItestTests.swift
//  SwiftUItestTests
//
//  Created by Kaikai Liu on 2/14/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import XCTest
import CoreLocation
@testable import SwiftUItest

class SwiftUItestTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func test_view_model_updates_latitude_and_longitude_properties() {
        let locations: [CLLocation] = [CLLocation(latitude: 12, longitude: 10)]

        let viewModel = LocationViewModel()

        viewModel.locationManager(CLLocationManager(), didUpdateLocations: locations)

        XCTAssertEqual(12, viewModel.userLatitude)
        XCTAssertEqual(10, viewModel.userLongitude)
    }
    
//    func testNetoworkSucceeds() {
//        // Zero rating
//        let datafetch = DataFetcher()
//        datafetch.getWeather()
//
////        XCTAssertNotNil(zeroRatingMeal)
////
////        // Highest positive rating
////        let positiveRatingMeal = ModelData.init(name: "Positive", photo: nil, rating: 5)
////        XCTAssertNotNil(positiveRatingMeal)
//    }

}
