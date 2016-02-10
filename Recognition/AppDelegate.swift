//
//  AppDelegate.swift
//  Recognition
//
//  Created by Nikolaus Heger on 11/16/15.
//  Copyright © 2015 Nikolaus Heger. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var settings = Settings()
    
    static func delegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate! as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
                
        // defaults
        settings.setupDefaults()
        
        // set up all our notifications and stuff
        setupNotificationCategoriesAndActions()
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            print("launching with notification: \(notification)")
            handleNotification(notification)
        }
        
        // appearance
        let textColor = UIColor.whiteColor()
        let bgColor = UIColor.blackColor()
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName : textColor,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-Medium", size: 26)!
        ]
        UINavigationBar.appearance().tintColor = textColor
        UINavigationBar.appearance().barTintColor = bgColor

        application.setStatusBarStyle(.LightContent, animated: false)
        
        
//        UIButton.appearance().tintColor = Constants.PurpleColor
//        UISwitch.appearance().onTintColor = Constants.PurpleColor
        
        return true
    }

    func setupNotificationCategoriesAndActions() {
        
        let types = UIUserNotificationType([.Badge, .Sound, .Alert])
        let recognitionCategory = UIMutableUserNotificationCategory()
        
        // Identifier to include in your push payload and local notification
        recognitionCategory.identifier = "RECOGNITION_CATEGORY";
        
        let acceptAction = UIMutableUserNotificationAction()
        acceptAction.identifier = "ACCEPT";
        acceptAction.title = "Done";
        acceptAction.activationMode = .Background
        acceptAction.destructive = false
        acceptAction.authenticationRequired = false

        let declineAction = UIMutableUserNotificationAction()
        declineAction.identifier = "DECLINE";
        declineAction.title = "Not now";
        declineAction.activationMode = .Background
        declineAction.destructive = true
        declineAction.authenticationRequired = false
        
        // Add the actions to the category and set the action context
        recognitionCategory.setActions([acceptAction, declineAction], forContext: .Default)
        // Set the actions to present in a minimal context
        recognitionCategory.setActions([acceptAction, declineAction], forContext: .Minimal)
        
        let categories = Set([recognitionCategory])
        
        let notificationSettings = UIUserNotificationSettings(forTypes: types, categories: categories)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        

        
    }
    
    // MARK: Handle Notifications
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("got notification: \(notification)")
        handleNotification(notification)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        print("handle 1 \(notification)")
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        print("handle 2 \(notification) \(responseInfo)")
    }
    
    func handleNotification(notification: UILocalNotification) {
        print("handling notification")
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

