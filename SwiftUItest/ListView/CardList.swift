//
//  CardList.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/5/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct CardList: View {
    @EnvironmentObject private var userData: UserData
    
    var body: some View {
        ScrollView {
            //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            ForEach(userData.dataitems) { dataitem in
                NavigationLink(
                    destination: ItemDetail(dataitem: dataitem)
                ) {
                    //Image("Mountain")
//                        .renderingMode(.original).buttonStyle(PlainButtonStyle())
                    CardView(title: "SMOOTHIE BOWL", description: "With extra coconut asdfjalksjdglaksjdlgkasldkgnhalksjdfalksdgkjalskfndglaksnfgdlkasfklg", image: Image("Mountain"), corner: "New", price: 15.00, peopleCount: 2, ingredientCount: 12, category: "Temperature", buttonHandler: nil)
                }
            }
        } //end list
    }
}

struct CardList_Previews: PreviewProvider {
    static var previews: some View {
        CardList().environmentObject(UserData())
    }
}
