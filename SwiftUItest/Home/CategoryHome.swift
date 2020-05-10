//
//  Home.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 3/13/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct CategoryHome: View {
    @State var showingProfile = false
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var authState: AuthenticationState
    
    var categories: [String: [DataItem]] {
        Dictionary(
            grouping: sampleDataItem,
            by: { $0.category.rawValue }
        )
    }
    
    var featured: [DataItem] {
        //sampleDataItem.filter{$0.isFeatured}
        sampleDataItem.filter{$0.isFeatured==true}
    }
    
    var profileButton: some View {
        Button(action: { self.showingProfile.toggle() }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .accessibility(label: Text("User Profile"))
                .padding()
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                FeaturedDataItems(dataitems: featured)
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .listRowInsets(EdgeInsets())
                
                ForEach(categories.keys.sorted(by: <), id: \.self) { key in
                    CategoryRow(categoryName: key, items: self.categories[key]!)
                }
                .listRowInsets(EdgeInsets())
                
//                if (userData.isLandscape)
//                {
//                    ForEach(categories.keys.sorted(), id: \.self) { key in
//                        CategoryRow(categoryName: key, items: self.categories[key]!)
//                    }
//                    .listRowInsets(EdgeInsets())
//                }else {
//                    ForEach(categories.keys.sorted(), id: \.self) { key in
//                        CategoryRow(categoryName: key, items: self.categories[key]!)
//                    }
//                    .listRowInsets(EdgeInsets())
//                }
                
//                NavigationLink(destination: LandmarkList()) {
//                    Text("See All")
//                }
            }
            .navigationBarTitle(Text("Featured"))
            .navigationBarItems(trailing: profileButton)
            .sheet(isPresented: $showingProfile) {
                //ProfileHost().environmentObject(self.userData)
                SettingsView().environmentObject(self.authState)
            }
        }
    }
}

struct FeaturedDataItems: View {
    var dataitems: [DataItem]
    var body: some View {
        //Old version
        //dataitems[0].image.resizable()

//        PageView(dataitems.map { feature in FeatureCard(featureImage: feature.featureImage,name: feature.name,detail: "Detailed description") })
//            .aspectRatio(contentMode: .fill)
//        .aspectRatio(4 / 2, contentMode: .fit)//3/2
        PageView(features.map {FeatureCardNew(landmark: $0)})
            .aspectRatio(4 / 2, contentMode: .fit)
    }
}

struct CategoryHome_Previews: PreviewProvider {
    static var previews: some View {
        CategoryHome().environmentObject(UserData())
    }
}
