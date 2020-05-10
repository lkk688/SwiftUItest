//
//  SignInView.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/15/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authState: AuthenticationState
    @State var email: String = ""
    @State var password: String = ""
    @State var passwordConf: String = ""
    @State var isShowingPassword = false
    @State private var showingErrorAlert = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    //@Binding
    //var authType: AuthenticationType
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 100)
                    .padding(.top, 20)
                
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                if isShowingPassword {
                    TextField("Password", text: $password)
                        .textContentType(.password)
                        .autocapitalization(.none)
                } else {
                    SecureField("Password", text: $password)
                }
                
                if self.authState.authType == .signup {
                    if isShowingPassword {
                        TextField("Password Confirmation", text: $passwordConf)
                            .textContentType(.password)
                            .autocapitalization(.none)
                    } else {
                        SecureField("Password Confirmation", text: $passwordConf)
                    }
                }
                
                Toggle("Show password", isOn: $isShowingPassword)
                //.foregroundColor(.white)
                
                //Action button, signup or signin
                Button(action:
                    {
                        //                switch self.authType {
                        //                case .login:
                        //                    self.authState.login(with: .emailAndPassword(email: self.email, password: self.password))
                        //
                        //                case .signup:
                        //                    self.authState.signup(email: self.email, password: self.password, passwordConfirmation: self.passwordConf)
                        //                }
                        self.emailAuthenticationTapped(authType: self.authState.authType)
                        
                }
                ) {
                    Text(self.authState.authType.text)
                        .font(.callout)
                }
                    //.buttonStyle(XCAButtonStyle())
                    .disabled(email.count == 0 && password.count == 0)
                
                //Google signin button
                Button(action: SocialLogin.attemptLoginGoogle,label: {
                        Image("google").frame(width: 20, height: 20)
                })
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background(Color.white)
                    .cornerRadius(8.0)
                    .shadow(radius: 4.0)
                
                //switch signin or logout
                Button(action: {
                    //footerButtonTapped
                    self.clearFormField()
                    if (self.authState.authType == .login)
                    {
                        self.authState.authType = .signup
                    }else
                    {
                        self.authState.authType = .login
                    }
                }) {
                    Text(self.authState.authType.footerText)
                        .font(.callout)
                }
                //.foregroundColor(.white)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 288)
            .alert(isPresented: $showingErrorAlert, content: {self.alert})
            .navigationBarItems(leading: Button(action: {
                print("Dismissing setting view...")
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel").bold()
            })
        }
        //.alert(isPresented: $showingPaymentAlert, content: {self.alert})
        //            .alert(item: $authState.$isAuthenticating, content: { error in
        //            Alert(title: Text("Error"), message: Text(error.localizedDescription))
        //        })
        //        .alert(item: $authState.error) { error in
        //            Alert(title: Text("Error"), message: Text(error.localizedDescription))
        //        }
    }
    
    private func emailAuthenticationTapped(authType: AuthenticationType) {
        //var authType: AuthenticationType
        switch authType {
        case .login:
            //authState.login(with: .emailAndPassword(email: email, password: password))
            authState.loginwithcompletion(with: .emailAndPassword(email: email, password: password)){ (result, error) in
                if error != nil {
                    print("Login Error")
                    self.showingErrorAlert = true
                } else {
                    if let user = result?.user {
                        //self.loggedInUser = user
                        let uid = user.uid
                        let email = user.email ?? "no email"
                        print("Logged In user:", uid, " email: ", email)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                }
            }
            
        case .signup:
            //authState.signup(email: email, password: password, passwordConfirmation: passwordConf)
            authState.signupwithcompletion(email: email, password: password, passwordConfirmation: passwordConf){ (result, error) in
                if error != nil {
                    print("Signjup Error")
                    self.showingErrorAlert = true
                } else {
                    if let user = result?.user {
                        //self.loggedInUser = user
                        let uid = user.uid
                        let email = user.email ?? "no email"
                        print("Signup user:", uid, " email: ", email)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                }
            }
        }
    }
    
    private func footerButtonTapped() {
        clearFormField()
        if (authState.authType == .login)
        {
            authState.authType = .signup
        }else
        {
            authState.authType = .login
        }
        //        if (authType == .login)
        //        {
        //            authType = .signup
        //        }else{
        //            authType = .login
        //        }
        //authType = authType == .signup ? .login : .signup
    }
    
    private func clearFormField() {
        email = ""
        password = ""
        passwordConf = ""
        isShowingPassword = false
    }
    
    var alert: Alert {
        Alert(title: Text("Error"), message:Text("Cannot login"), dismissButton: .default(Text("OK")))
    }
}



struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView().environmentObject(AuthenticationState.shared)
    }
}
