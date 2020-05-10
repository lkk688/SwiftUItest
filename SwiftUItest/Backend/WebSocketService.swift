//
//  WebSocketService.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/7/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class WebSocketService : ObservableObject {

    
    private let urlSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask?
    
    //test websocket: wscat -c wss://i6bvnlnf5d.execute-api.us-west-2.amazonaws.com/Test
    private let baseURL = URL(string: "wss://i6bvnlnf5d.execute-api.us-west-2.amazonaws.com/Test")!
    
    @Published var receivedmessage: String = ""
    
    private var cancellable: AnyCancellable? = nil
    
//    let didChange = PassthroughSubject<Void, Never>()
//    var priceResult: String = "" {
//        didSet {
//            didChange.send()
//        }
//    }
    
    
    init() {
        //This piece of code is option? If use this code, the UI part can use priceResult, otherwise, juse use price
//        cancellable = AnyCancellable($price
//            //.debounce(for: 0.5, scheduler: DispatchQueue.main)
//            .removeDuplicates()
//            .assign(to: \.priceResult, on: self))//\.priceResult
        
    }

    func connect() {
        
        stop()
        webSocketTask = urlSession.webSocketTask(with: baseURL)
        webSocketTask?.resume()
        
        sendPing()
        
        sendMessage()
        receiveMessage()
        //sendPing()
    }
    
    private func sendPing() {
        webSocketTask?.sendPing { (error) in
            if let error = error {
                print("Sending PING failed: \(error)")
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 10) { [weak self] in
                self?.sendPing()
            }
        }
    }

    func stop() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    private func sendMessage()
    {
        let string = "{\"message\":\"OnMessage\",\"data\":\"Hello from iOS\"}"
        
        let message = URLSessionWebSocketTask.Message.string(string)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive {[weak self] result in
            
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(.string(let str)):
                
                DispatchQueue.main.async{
                    print("received data: \(str)")
                    self?.receivedmessage = str//"\(result.data[0].p)"
                }
//                do {
//                    let decoder = JSONDecoder()
//                    let result = try decoder.decode(APIResponse.self, from: Data(str.utf8))
//                    DispatchQueue.main.async{
//                        self?.price = "\(result.data[0].p)"
//                    }
//                } catch  {
//                    print("error is \(error.localizedDescription)")
//                }
                
                self?.receiveMessage()
                
            default:
                print("default")
            }
        }
    }
    
}

//struct APIResponse: Codable {
//    var data: [PriceData]
//    var type : String
//
//    private enum CodingKeys: String, CodingKey {
//        case data, type
//    }
//}
//
//struct PriceData : Codable{
//
//    public var p: Float
//
//    private enum CodingKeys: String, CodingKey {
//        case p
//    }
//}
