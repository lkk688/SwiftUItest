//
//  SettingsView.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/15/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    //@ObservedObject var settingsViewModel = SettingsViewModel()
    
    //@Binding var showSheetView: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    //ref: https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-a-view-dismiss-itself
    
    @EnvironmentObject var authState: AuthenticationState
    //@State var displayname: String
    
    var body: some View {
        NavigationView {
            VStack {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 100)
                    .padding(.top, 20)
                
                Text("Thanks for joining")
                    .font(.title)
                
                Text("SJSU CMPE")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Form {
                    Section {
                        HStack {
                            Image("logo")
                                .resizable()
                                .frame(width: 17, height: 17)
                            Text("About SJSU")
                        }
                    }
                    Section {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Help & Feedback")
                        }
                        NavigationLink(destination: Text("About!") ) {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("About")
                            }
                        }
                    }
                    AccountSection().environmentObject(authState)
                    
                }
                
            }
            .navigationBarTitle(Text("Settings"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                print("Dismissing setting view...")
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").bold()
            })
        }
    }
}

struct AccountSection: View {
    //@ObservedObject var settingsViewModel: SettingsViewModel
    @State private var showSignInView = false
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        Section(footer: footer) {
            button
            
        }
    }
    
    var footer: some View {
        HStack {
            Spacer()
            if self.authState.loggedInUser != nil {
                VStack {
                    Text("Thanks for joining SJSU, \(self.authState.loggedInUser?.displayName ?? "No name")!")
                    Text("Logged in as \(self.authState.loggedInUser?.email ?? "No email")")
                }
            }
            else {
                Text("You're not logged in.")
            }
            Spacer()
        }
    }
    
    var button: some View {
        VStack {
            if self.authState.loggedInUser != nil {
                Button(action: { self.logout() }) {
                    HStack {
                        Spacer()
                        Text("Logout")
                        Spacer()
                    }
                }
            }else {
                Button(action: { self.login() }) {
                    HStack {
                        Spacer()
                        Text("Login")
                        Spacer()
                    }
                }
            }
            //      if settingsViewModel.isAnonymous {
            //        Button(action: { self.login() }) {
            //          HStack {
            //            Spacer()
            //            Text("Login")
            //            Spacer()
            //          }
            //        }
            //      }
            //      else {
            //        Button(action: { self.logout() }) {
            //          HStack {
            //            Spacer()
            //            Text("Logout")
            //            Spacer()
            //          }
            //        }
            //      }
        }
        .sheet(isPresented: self.$showSignInView) {
//            if self.settingsViewModel.isAnonymous {
//                SignInView(authType: AuthenticationType.login).environmentObject(AuthenticationState.shared)
//            }else{
//                SignInView(authType: AuthenticationType.signup).environmentObject(AuthenticationState.shared)
//            }
            SignInView().environmentObject(self.authState)
//            if self.authState.loggedInUser != nil {
//                SignInView(authType: AuthenticationType.login)
//            }else{
//                SignInView(authType: AuthenticationType.signup)
//            }
            
        }
    }
    
    func login() {
        self.showSignInView.toggle()
    }
    
    func logout() {
        //self.settingsViewModel.logout()
        self.authState.signout()
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
