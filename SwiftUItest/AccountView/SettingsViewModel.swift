//
//  SettingsViewModel.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/15/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
import Combine

class SettingsViewModel: ObservableObject {
@Published var user: User? //added after FirebaseAuth
@Published var isAnonymous = true
@Published var email: String = ""
@Published var displayName: String = ""
    //@Published var authState: AuthenticationState
    
    private var cancellables = Set<AnyCancellable>()
    //@EnvironmentObject var authState: AuthenticationState

//    init() {
//        authState.$loggedInUser.compactMap{ user in
//            user?.isAnonymous
//        }
//        .assign(to: \.isAnonymous, on: self)
//        .store(in: &cancellables)
//    }
    
    func logout() {
      //self.authenticationService.signOut()
    }
}
