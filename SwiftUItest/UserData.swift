//
//  UserData.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 3/13/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation

import Combine
import SwiftUI

final class UserData: ObservableObject {
    @Published var showFavoritesOnly = false
    @Published var dataitems = sampleDataItem
    @Published var profile = Profile.default
    @Published var isLandscape: Bool = false
    @Published var historyorder = sampleOrders
    
    @Published var featureditem = features
}
