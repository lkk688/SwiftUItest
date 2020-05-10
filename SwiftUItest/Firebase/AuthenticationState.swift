//
//  AuthenticationState.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/15/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

//import Foundation
import Combine
import AuthenticationServices
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

enum LoginOption {
    case signInWithApple
    case emailAndPassword(email: String, password: String)
}

class AuthenticationState: NSObject, ObservableObject, GIDSignInDelegate {
    @Published var loggedInUser: User?
    @Published var isAuthenticating = false
    @Published var error: NSError?
    @Published var authType: AuthenticationType
    
    static let shared = AuthenticationState()
    
    private let auth = Auth.auth()
    fileprivate var currentNonce: String?
    
    override private init() {
        loggedInUser = auth.currentUser
        authType = .login
        super.init()
        GIDSignIn.sharedInstance().delegate = self
        
        auth.addStateDidChangeListener(authStateChanged)
    }
    
    private func authStateChanged(with auth: Auth, user: User?) {
        print("Sign in state has changed.")
        //guard user != self.loggedInUser else { return }
        //self.loggedInUser = user
        if let user = user {
            self.loggedInUser = user
            let anonymous = user.isAnonymous ? "anonymously " : ""
            print("User signed in \(anonymous)with user ID \(user.uid). Email: \(user.email ?? "(empty)"), display name: [\(user.displayName ?? "(empty)")]")
            //save uid in UserDefaults
            UserDefaults.standard.setValue(user.uid, forKey: "uid")
            //update to Firestore
            updateuserinFirestore()
            
        }
        else {
            print("User signed out.")
            //self.signIn()
            removeuserinFirestore()
            UserDefaults.standard.removeObject(forKey: "uid")
        }
    }
    
    private func updateuserinFirestore()
    {
        let deviceToken = UserDefaults.standard.value(forKey:"fcmToken") as? String ?? "not found"
        
//        let date = Date()
//        let format = DateFormatter()
//        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let formattedDate = format.string(from: date)
        let documentID = UserDefaults.standard.value(forKey:"documentID")
        if (documentID != nil) //user already logged in, update the firestore
        {
            let docIDstr = documentID as! String
            Firestore.firestore().collection("users").document(docIDstr).updateData( [
                "UserID": self.loggedInUser?.uid ?? "Noid",
                "Displayname": self.loggedInUser?.displayName ?? "No name",
                "Email": self.loggedInUser?.email ?? "Unknow email",
                "Singintime": Timestamp(date: Date()),
                "FCMtoken": deviceToken
            ]){ err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document updated ")
                }
            }
        }else {//add new data
            var ref: DocumentReference? = nil
            ref = Firestore.firestore().collection("users").addDocument(data: [
                "UserID": self.loggedInUser?.uid ?? "Noid",
                "Displayname": self.loggedInUser?.displayName ?? "No name",
                "Email": self.loggedInUser?.email ?? "Unknow email",
                "Singintime": Timestamp(date: Date()),
                "FCMtoken": deviceToken
            ]){ err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    UserDefaults.standard.setValue(ref!.documentID, forKey: "documentID")
                }
            }
            //If the document does not exist, it will be created. If the document does exist, its contents will be overwritten with the newly provided data
        }
        
        
    }
    
    private func removeuserinFirestore()
    {
        let documentID = UserDefaults.standard.value(forKey:"documentID")
        if documentID != nil {
            let docIDstr = documentID as! String
            Firestore.firestore().collection("users").document(docIDstr).delete()
                { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    UserDefaults.standard.removeObject(forKey: "documentID")
                }
            }
        }
        
        
    }
    
    func loginwithcompletion(with loginOption: LoginOption, handler: @escaping AuthDataResultCallback) {
        self.isAuthenticating = true
        self.error = nil
        
        switch loginOption {
        case let .emailAndPassword(email, password):
            //handleSignInWith(email: email, password: password)
            auth.signIn(withEmail: email, password: password, completion: handler)
            
        case .signInWithApple:
            handleSignInWithApple()
        }
    }
    
    //    func login(with loginOption: LoginOption) {
    //        self.isAuthenticating = true
    //        self.error = nil
    //
    //        switch loginOption {
    //        case .signInWithApple:
    //            handleSignInWithApple()
    //
    //        case let .emailAndPassword(email, password):
    //            handleSignInWith(email: email, password: password)
    //        }
    //    }
    func signupwithcompletion(email: String, password: String, passwordConfirmation: String, handler: @escaping AuthDataResultCallback)
    {
        guard password == passwordConfirmation else {
            self.error = NSError(domain: "", code: 9210, userInfo: [NSLocalizedDescriptionKey: "Password and confirmation does not match"])
            return
        }
        
        self.isAuthenticating = true
        self.error = nil
        
        auth.createUser(withEmail: email, password: password, completion: handler)
    }
    
    func signup(email: String, password: String, passwordConfirmation: String) {
        guard password == passwordConfirmation else {
            self.error = NSError(domain: "", code: 9210, userInfo: [NSLocalizedDescriptionKey: "Password and confirmation does not match"])
            return
        }
        
        self.isAuthenticating = true
        self.error = nil
        
        auth.createUser(withEmail: email, password: password, completion: handleAuthResultCompletion)
    }
    
    private func handleSignInWith(email: String, password: String) {
        auth.signIn(withEmail: email, password: password, completion: handleAuthResultCompletion)
    }
    
    private func handleAuthResultCompletion(auth: AuthDataResult?, error: Error?) {
        DispatchQueue.main.async {
            self.isAuthenticating = false
            if let user = auth?.user {
                self.loggedInUser = user
                let uid = user.uid
                let email = user.email ?? "no email"
                print("Logged In user:", uid, " email: ", email)
            } else if let error = error {
                self.error = error as NSError
            }
        }
    }
    
    func signout() {
        try? auth.signOut()
        self.loggedInUser = nil
    }
    
    func profileChangeRequest()
    {
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = "Test displayname"
        changeRequest?.commitChanges { (error) in
            print(error!.localizedDescription)
        }
    }
    
    private func handleSignInWithApple() {
        
    }
    
    //callback function for Google signin
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) {
            (user, error) in
            if error != nil {
                return
            }
        }
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        print("Google signout")
        print(error.localizedDescription)
    }
    
}

enum AuthenticationType: String {
    case login
    case signup
    
    var text: String {
        rawValue.capitalized
    }
    
    var assetBackgroundName: String {
        self == .login ? "login" : "signup"
    }
    
    var footerText: String {
        switch self {
        case .login:
            return "Not a member, signup"
            
        case .signup:
            return "Already a member? login"
        }
    }
}
