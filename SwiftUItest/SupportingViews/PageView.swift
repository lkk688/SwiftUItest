//
//  PageView.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 3/13/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    @State var currentPage = 0

    init(_ views: [Page]) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
            
            PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
            .padding(.trailing)
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
//        PageView(features.map { FeatureCard(featuredataitem: $0) })
//            .aspectRatio(3 / 2, contentMode: .fit)
        
//        PageView(features.map { _ in FeatureCard(featureImage: Image("Mountain"),name: "Name",detail: "Detailed description") })
//        .aspectRatio(3 / 2, contentMode: .fit)
        
//        PageView(features.map { feature in FeatureCard(featureImage: feature.featureImage,name: feature.name,detail: "Detailed description") })
//        .aspectRatio(3 / 2, contentMode: .fit)
        
        PageView(features.map { FeatureCardNew(landmark: $0) })
        .aspectRatio(3 / 2, contentMode: .fit)
        
    }
}
