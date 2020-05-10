//
//  PushNotificationManager.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/16/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseFirestore

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    //    let userID: String
    //    init(userID: String) {
    //        self.userID = userID
    //        super.init()
    //    }
    
    func registerForPushNotifications() {
        //ref: https://firebase.google.com/docs/cloud-messaging/ios/client
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            //Access the registration token
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        //updateFirestorePushTokenIfNeeded()
        //let token = Messaging.messaging().fcmToken//this token is nil
        //let deviceTokenString = token.map { String(format: "%02.2hhx", $0) }//.joined()

        //Added Code to display notification when app is in Foreground
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        
        Messaging.messaging().subscribe(toTopic: "highScores") { error in
          print("Subscribed to highScores topic")
        }
    }
    
    //FCM provides a registration token via FIRMessagingDelegate's messaging:didReceiveRegistrationToken: method. The FCM SDK retrieves a new or existing token during initial app launch and whenever the token is updated or invalidated.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        UserDefaults.standard.setValue(fcmToken, forKey: "fcmToken")
        let documentID = UserDefaults.standard.value(forKey:"documentID")
        if (documentID != nil) //user already logged in, update the firestore
        {
            let docIDstr = documentID as! String
            Firestore.firestore().collection("users").document(docIDstr).updateData(["FCMtoken": fcmToken])
                { err in
                if let err = err {
                    print("Error updating fcmToken document: \(err)")
                } else {
                    print("fcmToken successfully updated to the Firestore!")
                }
            }
        }
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        //other parts of the App can observe this notification and do something.
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //run when click the notification in the notification center
        print(response)
    }
    
    func handleSubscribe(topic: String)
    {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            print("Subscribed to weather topic")
        }
    }
    
    @objc func displayFCMToken(notification: NSNotification){
        guard let userInfo = notification.userInfo else {return}
        if let fcmToken = userInfo["token"] as? String {
            print("Received FCM token: \(fcmToken)")
        }
    }
    
//    func updateFirestorePushTokenIfNeeded() {
//        if let token = Messaging.messaging().fcmToken {
//            let usersRef = Firestore.firestore().collection("users").document("testiosuser1")
//            usersRef.setData(["fcmToken": token], merge: true)
//        }
//    }
    
}
