//
//  VisionView.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/30/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

enum ActiveSheet {
    case first, second
}


struct VisionView: View {
    @State var image: Image? = nil
    @State var showCaptureImageView: Bool = false
    @State var showCaptureVideoView: Bool = false
    @State var text: String? = nil
    @State private var activeSheet: ActiveSheet = .first
    
    var body: some View {
        VStack {
            
            image?.resizable()
                .frame(width: 400, height: 300)
                .aspectRatio(contentMode: .fill)
                .padding(.vertical, CGFloat(10))
                //                .clipShape(Circle())
                //                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
            if text != nil {
                Text(text!)
            }
            
            HStack{
                Button(action: {
                    self.showCaptureImageView.toggle()
                    self.activeSheet = .first
                }) {
                    Text("Choose photos")
                }
                
                Button(action: {
                    //self.showCaptureVideoView.toggle()
                    self.showCaptureImageView.toggle()
                    self.activeSheet = .second
                }) {
                    Text("Start camera")
                }
            }
            
        }.sheet(isPresented: self.$showCaptureImageView){
            if self.activeSheet == .first {
                CaptureImageView(isShown: self.$showCaptureImageView, image: self.$image, text: self.$text)
            }else {
                CameraView(isShown: self.$showCaptureImageView)
            }
            
        }
    }
}

struct VisionView_Previews: PreviewProvider {
    static var previews: some View {
        VisionView()
    }
}
