//
//  SensorViewModel.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/9/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation
import Combine

class BackendViewModel: ObservableObject {
    private let backend = BackendAPI()
    
    private var bag = Set<AnyCancellable>()
    
    @Published private(set) var sensordata: FirebaseResponse?// BackendResponse?//[BackendResponse] = []
    
    @Published var activityshouldAnimate = false//false
    
//    init() {
//        //sensordata: BackendResponse self.sensordata = sensordata
//    }
    
    func getsecureData() {
        backend.backend_secureGET(withDeviceID: "webnew2", type: "web")
    }
    
    func getSensorData() {
        backend.firebasegetPubData(queryid: "test04")
        .decode(type: FirebaseResponse.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { print ("Received completion: \($0).") },
            receiveValue: { val in
                print ("Received data: \(val).")
                self.sensordata = val
            })
        .store(in: &bag)
//        backend.getPubData()
//            .decode(type: BackendResponse.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { print ("Received completion: \($0).") },
//                receiveValue: { val in
//                    print ("Received data: \(val).")
//                    self.sensordata = val
//                })
//            .store(in: &bag)
        
    }
    
}
