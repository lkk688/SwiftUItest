//
//  FeatureCardNew.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 3/26/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct FeatureCardNew: View {
    var landmark: DataItem
    
    var body: some View {
        //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        landmark.featureImage?
            .resizable()
            .aspectRatio(4 / 2, contentMode: .fit)//3 / 2
            .overlay(TextOverlayNew(landmark: landmark))
    }
}

struct TextOverlayNew: View {
    var landmark: DataItem
    
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
                Text(landmark.name)
                    .font(.title)
                    .bold()
                Text(landmark.park)
            }
            .padding()
        }
        .foregroundColor(.white)
    }
}


struct FeatureCardNew_Previews: PreviewProvider {
    static var previews: some View {
        FeatureCardNew(landmark: features[0])
    }
}
