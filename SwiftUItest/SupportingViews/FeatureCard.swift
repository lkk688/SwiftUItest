//
//  FeatureCard.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 3/13/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct FeatureCard: View {
    
    //var featuredataitem: DataItem
    var featureImage: Image?
    var name: String
    var detail: String
    
    var body: some View {
        //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        featureImage?
        .resizable()
            .aspectRatio(4/2, contentMode: .fit)//3/2
            .overlay(TextOverlay(name: name, detail: detail))
    }
}

struct TextOverlay: View {
    //var currentItem: DataItem
    var name: String
    var detail: String
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [Color.black.opacity(0.6), Color.black.opacity(0)]),
            startPoint: .bottom,
            endPoint: .center)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(gradient)
            VStack(alignment: .leading) {
                Text(name)
                    .font(.title)
                    .bold()
                Text(detail)
            }
            .padding()
        }
        .foregroundColor(.white)
    }
}


struct FeatureCard_Previews: PreviewProvider {
    static var previews: some View {
        FeatureCard(featureImage: Image("Mountain"),name: "Name",detail: "Detailed description")
    }
}
