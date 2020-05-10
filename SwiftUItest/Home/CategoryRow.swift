//
//  CategoryRow.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 3/13/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct CategoryRow: View {
    var categoryName: String
    var items: [DataItem]
    @EnvironmentObject var userData: UserData
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(self.categoryName)
                .font(.headline)
                .padding(.leading, 15)
                .padding(.top, 5)
            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(alignment: .center, spacing: 0) {
//                    ForEach(self.items) { item in
//                        NavigationLink(
//                            destination: ItemDetail(
//                                dataitem: item
//                            )
//                        ) {
//                            CategoryItem(categoryItem: item)
//                        }
//                    }
//                }
//            }
//            .frame(height: 185)
            
            if (userData.isLandscape == true)
            {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 10) {
                        ForEach(self.items) { item in
                            NavigationLink(
                                destination: ItemDetail(
                                    dataitem: item
                                )
                            ) {
                                CategoryItem(categoryItem: item)
                            }
                        }
                    }
                }
                .frame(height: 185)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(self.items) { item in
                            NavigationLink(
                                destination: ItemDetail(
                                    dataitem: item
                                )
                            ) {
                                CategoryItem(categoryItem: item)
                            }
                        }
                    }
                }
                .frame(height: 185)
            }
            //Divider()
        }//.padding(.top, 8)
    }
}

struct CategoryItem: View {
    var categoryItem: DataItem
    
    var body: some View {
        VStack(alignment: .leading) {
            categoryItem.image
                .renderingMode(.original)
                .resizable()
                .frame(width: 155, height: 155)
                .cornerRadius(10)
                .scaledToFill()
                //.scaledToFit()//new added to solve the problem of missing mountain data in landscape view
            Text(categoryItem.name)
                .foregroundColor(.primary)
                .font(.caption)
        }
        .padding(.leading, 15)
    }
}

struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRow(
            categoryName: sampleDataItem[0].category.rawValue,
            items: Array(sampleDataItem.prefix(4))
        ).environmentObject(UserData())
    }
}
