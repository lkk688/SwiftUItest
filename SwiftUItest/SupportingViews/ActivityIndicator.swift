//
//  ActivityIndicator.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 3/26/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    @Binding var shouldAnimate: Bool
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        // Create UIActivityIndicatorView
        return UIActivityIndicatorView()
    }

    func updateUIView(_ uiView: UIActivityIndicatorView,
                      context: Context) {
        // Start and stop UIActivityIndicatorView animation
        if self.shouldAnimate {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}

//struct ActivityIndicator_Previews: PreviewProvider {
//    @State var animate = true
//    static var previews: some View {
//        ActivityIndicator(shouldAnimate: true)
//    }
//}
