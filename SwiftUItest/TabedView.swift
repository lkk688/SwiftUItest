//
//  TabedView.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 2/20/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct TabedView: View {
    @State private var tabSelected = 0
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        TabView(selection: $tabSelected) {
            CategoryHome()
            .tabItem {
                Image(systemName: (tabSelected == 0 ? "house" : "house.fill") )
                Text("Home")
            }.tag(0)
            NavigationView() {
                OrderForm()
            }
            .tabItem {
                Image(systemName: (tabSelected == 0 ? "doc.text.fill" : "doc.text") )
                Text("New Order")
            }.tag(1)
            NavigationView() {
                OrderHistory()//sampleOrders)
            }
            .tabItem {
                Image(systemName: (tabSelected == 1 ? "clock.fill" : "clock"))
                Text("History")
            }.tag(2)
            
            WeeklyWeatherView(viewModel: WeeklyWeatherViewModel(weatherFetcher: DataFetcher()))
            .tabItem {
                Image(systemName: (tabSelected == 0 ? "cloud.sun.rain" : "cloud.sun.rain.fill") )
                Text("Weather")
            }.tag(3)
            
            //SensorUIView()
            VisionView()
            .tabItem {
                Image(systemName: (tabSelected == 0 ? "person.circle" : "person.circle.fill") )
                Text("Me")
            }.tag(4)
        }
    }
}

struct TabedView_Previews: PreviewProvider {
    static var previews: some View {
        TabedView().environmentObject(UserData())
    }
}
