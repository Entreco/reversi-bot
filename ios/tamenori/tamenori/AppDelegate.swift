//
//  AppDelegate.swift
//  tamenori
//
//  Created by Remco Janssen on 23/05/2018.
//  Copyright © 2018 Entreco. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var API_KEY = "AIzaSyA7ruSb75KcdYojOy4UDX-JNC_vagp01no"
    var GOOGLE_APP_ID = "1:784102336192:ios:0b3ceae76bb25673"
    var SENDER_ID = "784102336192"
    var DATABASE_URL = "https://reversi-wars.firebaseio.com"
    
    var playersRef: DatabaseReference!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let options = FirebaseOptions(googleAppID: GOOGLE_APP_ID, gcmSenderID: SENDER_ID)
        options.bundleID = "nl.entreco.reversi.tamenori"
        options.apiKey = API_KEY
        options.databaseURL = DATABASE_URL
        FirebaseApp.configure(name: "Reversi", options: options)
        
        guard let fbApp = FirebaseApp.app(name: "Reversi")
            else { assert(false, "Could not retrieve Reversi app") }
        
        let ref = Database.database(app: fbApp).reference().child("players")
        playersRef = ref.childByAutoId()
        
        // Add your bot with {"name":"<your bot name>"}
        playersRef.child("public").child("name").setValue("iOS - BOT")
        
        
        // Now Proove you're online by playing PingPong
        playersRef.child("public").child("ping").observe(.value) { snapshot in
            self.playersRef.child("public").child("ping").setValue("Fo shizzle")
        }
        
        
        // Listen for Game participation
        playersRef.child("matches").observe(.childAdded, with: { (snapshot) -> Void in
            // Oh dear, Someone invited me to play a match of Reversi
            let moveRef = snapshot.ref.child("move")
            let turnRef = snapshot.ref.child("board")
            
            turnRef.observe(.value) { snapshot in
                self.submitMove(moveRef)
            }
            
            moveRef.observe(.value) { snapshot in
                if(snapshot.value != nil && snapshot.value is String){
                    if("rejected".elementsEqual(snapshot.value as! String)){
                        self.submitMove(moveRef)
                    }
                }
            }
        })
        
        
        return true
    }
    
    func submitMove(_ ref: DatabaseReference){
        let row = Int(arc4random_uniform(7) + 1)
        let col = Int(arc4random_uniform(7) + 1)
        ref.setValue(String(format : "{\"row\":%d, \"col\":%d}", row, col))
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

