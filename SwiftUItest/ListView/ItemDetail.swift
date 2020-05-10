//
//  ItemDetail.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 3/13/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct ItemDetail: View {
    @EnvironmentObject var userData: UserData
    var dataitem: DataItem
    
    var itemIndex: Int {
        userData.dataitems.firstIndex(where: {
            $0.id == dataitem.id
        })!
    }
    
    var body: some View {
        //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        VStack {
            MapView(coordinate: dataitem.locationCoordinate)
                .edgesIgnoringSafeArea(.top)
                .frame(height: 300)
            
            CircleImage(image: dataitem.image)
                .offset(x: 0, y: -130)
                .padding(.bottom, -130)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(dataitem.name)
                        .font(.title)
                    
                    Button(action: {
                        self.userData.dataitems[self.itemIndex]
                            .isFavorite.toggle()
                    }) {
                        if self.userData.dataitems[self.itemIndex].isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.yellow)
                        } else {
                            Image(systemName: "star")
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                
                HStack(alignment: .top) {
                    Text(dataitem.park)
                        .font(.subheadline)
                    Spacer()
                    Text(dataitem.state)
                        .font(.subheadline)
                }
            }
            .padding()
            
            Spacer()
        }
    }
}

struct ItemDetail_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        
        return ItemDetail(dataitem: userData.dataitems[0])
            .environmentObject(userData)
    }
}
