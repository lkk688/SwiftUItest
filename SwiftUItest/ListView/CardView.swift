//
//  CardView.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/5/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

//ref: https://trailingclosure.com/product-card-in-swiftui/
var buttoncolor: Color = Color(red: 231/255, green: 119/255, blue: 112/255)

struct CardView: View {
    var image:Image     // Featured Image
    var price:Double    // USD
    var corner:String
    var title:String    // Product Title
    var description:String // Product Description
    var ingredientCount:Int // # of Ingredients
    var peopleCount:Int     // Servings
    var category:String?    // Optional Category
    var buttonHandler: (()->())?
    
    init(title:String, description:String, image:Image, corner: String, price:Double, peopleCount:Int, ingredientCount:Int, category:String?, buttonHandler: (()->())?) {
        
        self.title = title
        self.description = description
        self.image = image
        self.corner = corner
        self.price = price
        self.peopleCount = peopleCount
        self.ingredientCount = ingredientCount
        self.category = category
        self.buttonHandler = buttonHandler
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            
            // Main Featured Image - Upper Half of Card
            self.image
                .renderingMode(.original)
                .resizable()
                .scaledToFill()
                .frame(minWidth: nil, idealWidth: nil, maxWidth: UIScreen.main.bounds.width, minHeight: nil, idealHeight: nil, maxHeight: 300, alignment: .center)
                .clipped()
                .overlay(
                    Text(corner)
                        .fontWeight(Font.Weight.medium)
                        .font(Font.system(size: 16))
                        .foregroundColor(Color.white)
                        .padding([.leading, .trailing], 16)
                        .padding([.top, .bottom], 8)
                        .background(Color.black.opacity(0.5))
                    .mask(RoundedCorners(topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 15 ))
                    , alignment: .topLeading)
                .overlay(
                    ZStack(alignment:.bottomLeading){
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.clear, .black]),
                                                 startPoint: .center, endPoint: .bottom))
                            .clipped()
                            .cornerRadius(12.0)
                            
                        tileview(title: self.title, description: self.description)
                    }
                    )
            
            
            // Stack bottom half of card
//            VStack(alignment: .leading, spacing: 0) {
//                Text(self.title)
//                    .fontWeight(Font.Weight.heavy)
//                    .padding(.vertical, 5)
//                Text(self.description)
//                    .font(Font.custom("HelveticaNeue-Bold", size: 16))
//                    .foregroundColor(Color.gray)
//                    .padding(.vertical, 5)
//            }.padding(.horizontal, 20)
            
            
            // 'Based on:' Horizontal Category Stack
            HStack(alignment: .center, spacing: 6) {
                
                if category != nil {
                    Text("Type:")
                        .font(Font.system(size: 13))
                        .fontWeight(Font.Weight.heavy)
                    HStack {
                        Text(category!)
                        .font(Font.custom("HelveticaNeue-Medium", size: 12))
                            .padding([.leading, .trailing], 10)
                            .padding([.top, .bottom], 5)
                        .foregroundColor(Color.white)
                    }
                    .background(Color(red: 43/255, green: 175/255, blue: 187/255))
                    .cornerRadius(7)
                    Spacer()
                }
                
                HStack(alignment: .center, spacing: 0) {
                    Text("Count:")
                        //.foregroundColor(Color.gray)
                    Text("\(self.ingredientCount)")
                }.font(Font.custom("HelveticaNeue", size: 14))
                
            }
            .padding([.top, .bottom, .leading, .trailing], 8)
            
            // Horizontal Line separating details and price
            Divider()
            //HorizontalLine(color: Color.gray.opacity(0.3))
                .padding([.leading, .trailing], -12)
            
            // Price and Buy Now Stack
            HStack(alignment: .center, spacing: 4) {
                Text("Sensor Value: ")
                .font(Font.system(size: 13))
                .fontWeight(Font.Weight.bold)
                //.foregroundColor(Color.gray)
                Text(String.init(format: "%.1f", arguments: [self.price]))
                    .fontWeight(Font.Weight.heavy)
                
                Spacer()
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15, alignment: .center)
                    .foregroundColor(buttoncolor)
                    //.colorMultiply(Color(red: 231/255, green: 119/255, blue: 112/255))
                    .onTapGesture {
                        self.buttonHandler?()
                }
                Text("CONNECT")
                    .fontWeight(Font.Weight.heavy)
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

struct tileview: View {
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
                //.frame(minWidth: nil, idealWidth: nil, maxWidth: UIScreen.main.bounds.width, minHeight: nil, idealHeight: nil, maxHeight: 60, alignment: .center)
        }.padding(.horizontal, 20)
    }
}

struct RoundedCorners: Shape {
    var topLeft: CGFloat = 0.0
    var topRight: CGFloat = 0.0
    var bottomLeft: CGFloat = 0.0
    var bottomRight: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        
        let topLeft = min(self.topLeft, height/2, width/2)
        let topRight = min(self.topRight, height/2, width/2)
        let bottomLeft = min(self.bottomLeft, height/2, width/2)
        let bottomRight = min(self.bottomRight, height/2, width/2)

        path.move(to: CGPoint(x: width/2, y: 0))
        path.addLine(to: CGPoint(x: width - topRight, y: 0))
        path.addArc(center: CGPoint(x: width - topRight, y: topRight),
                    radius: topRight,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)

        path.addLine(to: CGPoint(x: width, y: height - bottomRight))
        path.addArc(center: CGPoint(x: width - bottomRight, y: height - bottomRight),
                    radius: bottomRight,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)

        path.addLine(to: CGPoint(x: bottomLeft, y: height))
        path.addArc(center: CGPoint(x: bottomLeft, y: height - bottomLeft),
                    radius: bottomLeft,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: topLeft))
        path.addArc(center: CGPoint(x: topLeft, y: topLeft),
                    radius: topLeft,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)

        return path
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(title: "SMOOTHIE BOWL", description: "With extra coconut asdfjalksjdglaksjdlgkasldkgnhalksjdfalksdgkjalskfndglaksnfgdlkasfklg", image: Image("Mountain"), corner: "New", price: 15.00, peopleCount: 2, ingredientCount: 12, category: "Temperature", buttonHandler: nil)
    }
}
