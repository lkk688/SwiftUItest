//
//  SocialLogin.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/16/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct SocialLogin: UIViewRepresentable {

    func makeUIView(context: UIViewRepresentableContext<SocialLogin>) -> UIView {
        return UIView()
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<SocialLogin>) {
    }

    static func attemptLoginGoogle(){
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
        GIDSignIn.sharedInstance()?.signIn()
        }
}
