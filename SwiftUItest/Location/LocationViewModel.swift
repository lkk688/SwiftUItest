//
//  LocationViewModel.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 3/26/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

//It inherits from NSObject, since it will implement CLLocationManagerDelegate protocol for observing location changes.
class LocationViewModel: NSObject, ObservableObject{
  
    @Published var userLatitude: Double = 0
    @Published var userLongitude: Double = 0
    @Published var location: CLLocation?
    @Published var placemark: CLPlacemark?
        //placemark?.name shows the street name
    @Published var status: CLAuthorizationStatus?
    
    private let geocoder = CLGeocoder()
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    private func geocode() {
        guard let location = self.location else { return }
        geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
            if error == nil {
                self.placemark = places?[0]

            } else {
                self.placemark = nil
            }
        })
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLatitude = location.coordinate.latitude
        userLongitude = location.coordinate.longitude
        self.location = location
        //print(location)
        self.geocode()
    }
}
