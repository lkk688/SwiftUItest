//
//  SensorUIView.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/7/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI
import UserNotifications
import FirebaseFirestore

struct SensorUIView: View {
    @ObservedObject var service = WebSocketService()
    
    @ObservedObject var viewmodel = BackendViewModel()
    
    var body: some View {
        NavigationView(){
            VStack{
                HStack{
                    Text("Sensor value: ")
                    //Text(viewmodel.sensordata?.message.sensorData.temperature ?? "No data")
                    Text(viewmodel.sensordata?.payload.value ?? "No data")
                    Button(action: {
                        self.viewmodel.getSensorData()
                    }) {
                        HStack {
                            Image(systemName: "envelope.open.fill")
                            Text("Get data from backend")
                        }
                    }
                }
                HStack{
                    Text("WS Message:")
                    Text(service.receivedmessage)
                }
                Button("Request Permission") {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("All set!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
//                Button("Send Notification") {
//                    let content = UNMutableNotificationContent()
//                    content.title = "Test notification"
//                    content.subtitle = "Send from local"
//                    content.sound = UNNotificationSound.default
//
//                    // show this notification five seconds from now
//                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//                    // choose a random identifier
//                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//                    // add our notification request
//                    UNUserNotificationCenter.current().add(request)
//                }
                
                Button("Send Remote Notification") {
                    let date = Date()
                    let format = DateFormatter()
                    format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let formattedDate = format.string(from: date)
                    var ref: DocumentReference? = nil
                    ref = Firestore.firestore().collection("messages").addDocument(data: [
                        "name": "test",
                        "profilePicUrl": "/images/firebase-logo.png",
                        "text": "testing FCM",
                        "timestamp": formattedDate
                    ]){ err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                }
            }
            //            ScrollView{
            //
            //
            //                SensorCardView(title: "Temperature Sensor", description: "This sensor is deployed in SJSU", image: Image("Mountain"), sensorval: viewmodel.sensordata?.message.sensorData.temperature ?? "No data", wsmessage: service.receivedmessage, buttonHandler: nil)
            //            }
        }.navigationBarTitle(Text("Sensor Card"))
            .onAppear {
                self.service.connect()//connect
                self.viewmodel.getSensorData()//getSensorData()
        }
    }
}

struct SensorUIView_Previews: PreviewProvider {
    static var previews: some View {
        SensorUIView()
    }
}



struct SensorCardView: View {
    var image:Image     // Featured Image
    var sensorval:String    // USD
    var title:String    // Product Title
    var description:String // Product Description
    var wsmessage:String?    // Optional Category
    var buttonHandler: (()->())?
    
    var buttoncolor: Color = Color(red: 231/255, green: 119/255, blue: 112/255)
    
    init(title:String, description:String, image:Image, sensorval:String, wsmessage:String?, buttonHandler: (()->())?) {
        
        self.title = title
        self.description = description
        self.image = image
        self.sensorval = sensorval
        self.wsmessage = wsmessage
        self.buttonHandler = buttonHandler
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            
            // Main Featured Image - Upper Half of Card
            self.image
                .renderingMode(.original)
                .resizable()
                .scaledToFill()
                .frame(minWidth: nil, idealWidth: nil, maxWidth: UIScreen.main.bounds.width, minHeight: nil, idealHeight: nil, maxHeight: 250, alignment: .center)
                .clipped()
                .overlay(
                    ZStack(alignment:.bottomLeading){
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.clear, .black]),
                                                 startPoint: .center, endPoint: .bottom))
                            .clipped()
                        
                        sensortileview(title: self.title, description: self.description)
                })
            
            //
            HStack(alignment: .center, spacing: 6) {
                Text("WS Message:")
                    .font(Font.system(size: 13))
                    .fontWeight(Font.Weight.heavy)
                HStack {
                    Text(wsmessage!)
                        .font(Font.custom("HelveticaNeue-Medium", size: 12))
                        .padding([.leading, .trailing], 10)
                        .padding([.top, .bottom], 5)
                        .foregroundColor(Color.white)
                }
                .background(Color(red: 43/255, green: 175/255, blue: 187/255))
                .cornerRadius(7)
                
            }
            .padding([.top, .bottom, .leading, .trailing], 8)
            
            // Horizontal Line separating details and price
            Divider()
                .padding([.leading, .trailing], -12)
            
            // Last section
            HStack(alignment: .center, spacing: 4) {
                Text("Sensor Value: ")
                    .font(Font.system(size: 13))
                    .fontWeight(Font.Weight.bold)
                //.foregroundColor(Color.gray)
                Text(String.init(format: "%.1f", arguments: [self.sensorval]))
                    .fontWeight(Font.Weight.heavy)
                
                Spacer()
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15, alignment: .center)
                    .foregroundColor(buttoncolor)
                    .onTapGesture {
                        self.buttonHandler?()
                }
            }.padding([.top, .bottom, .leading, .trailing], 8)
        }
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.6), radius: 20, x: 10, y: 8)
    }
}

struct sensortileview: View {
    var title: String
    var description: String
    
    var body: some View {
        // Stack bottom half of card
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .fontWeight(Font.Weight.heavy)
                .padding(.vertical, 5)
                .foregroundColor(Color.white)
            Text(description)
                .font(Font.custom("HelveticaNeue-Bold", size: 16))
                .foregroundColor(Color.white)//Color.gray
                .padding(.vertical, 1)
                .lineLimit(3)
        }.padding(.horizontal, 20)
    }
}
