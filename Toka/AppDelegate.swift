//
//  AppDelegate.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 15/08/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if launchOptions != nil{
            if let notification = launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey]{
                 print("Aplicacion Abierta desde Notificación: \(notification)")
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if NSUserDefaults.standardUserDefaults().boolForKey("USER_LOGGED"){
            self.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("Slider")
        }else{
            self.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("MainNC")
        }
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = deviceToken.description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "")
        NSLog("Token=%@", token)
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: "TOKEN")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        if let info = userInfo["aps"] as? [String:AnyObject]{
            if let badge = info["badge"] as? Int{
                NSLog("Badge=%@", badge)
                NSUserDefaults.standardUserDefaults().setValue(badge, forKey: "BADGE")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "PONBADGE", object: nil))
            }
        }
    }

}

