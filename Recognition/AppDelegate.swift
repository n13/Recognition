//
//  AppDelegate.swift
//  Recognition
//
//  Created by Nikolaus Heger on 11/16/15.
//  Copyright © 2015 Nikolaus Heger. All rights reserved.
//

import UIKit

enum NotificationStateMachine:Int {
    case notYetAsked = 0
    case inProgressBeforeDialog = 1
    case inProgressAfterDialog = 2
    case askedAndAnswered = 3
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var settings = Settings()
    
    var notificationState: NotificationStateMachine = .notYetAsked
    
    var notificationsRegistered = false
    
    static func delegate() -> AppDelegate {
        return UIApplication.shared.delegate! as! AppDelegate
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //UIFont.listFonts() // DEBUG
        
        // track notifications state
        notificationState = .notYetAsked
        
        // Settings defaults
        settings.setupDefaults()
        
        // Set up and register our notifications
        setupNotificationCategoriesAndActions()
        
        // Make sure the engine is on
        ReminderEngine.reminderEngine.initEngine()
        
        // Appearance defaults
        application.setStatusBarStyle(.lightContent, animated: false)
        UIBarButtonItem.appearance().tintColor = Constants.ActiveColor
        UIButton.appearance().tintColor = Constants.ActiveColor
        UISwitch.appearance().onTintColor = Constants.ActiveColor
        UINavigationBar.appearance().tintColor = Constants.ActiveColor
        let font  = UIFont(name: Constants.RegularFont, size: 20.0)
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font : font!
        ]
        
        // Handle incoming notifications - app start because user pushed on a notification
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
            print("launching with notification: \(notification)")
            handleNotification(notification)
        }
        
        return true
    }
    
    func setupNotificationCategoriesAndActions() {
        
        let types = UIUserNotificationType([.badge, .sound, .alert])
        let recognitionCategory = UIMutableUserNotificationCategory()
        
        // Identifier to include in your push payload and local notification
        recognitionCategory.identifier = Constants.NotificationCategory
        
        let acceptAction = UIMutableUserNotificationAction()
        acceptAction.identifier = "ACCEPT"
        acceptAction.title = "Done"
        acceptAction.activationMode = .background
        acceptAction.isDestructive = false
        acceptAction.isAuthenticationRequired = false

        let declineAction = UIMutableUserNotificationAction()
        declineAction.identifier = "DECLINE"
        declineAction.title = "Not now"
        declineAction.activationMode = .background
        declineAction.isDestructive = true
        declineAction.isAuthenticationRequired = false
        
        // Add the actions to the category and set the action context
        recognitionCategory.setActions([acceptAction, declineAction], for: .default)
        // Set the actions to present in a minimal context
        recognitionCategory.setActions([acceptAction, declineAction], for: .minimal)
        
        let categories = Set([recognitionCategory])
        
        let notificationSettings = UIUserNotificationSettings(types: types, categories: categories)
        
        notificationState = .inProgressBeforeDialog
        
        // this pops the dialog
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
    
    // this will be called after notifications are registered, and after the user dialog for registering notifications for the first time
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        //print("DID register \(notificationSettings)")
        notificationsRegistered = true
        notificationState = .askedAndAnswered
        postNotification(Constants.UserAnsweredNotificationsDialog)
    }
    
    // MARK: Handle Notifications
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("got notification: \(notification)")
        handleNotification(notification)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        print("handle 1 \(notification)")
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        print("handle 2 \(notification) \(responseInfo)")
    }
    
    func handleNotification(_ notification: UILocalNotification) {
        print("handling notification")
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.LocalNotificationArrived), object: nil, userInfo: nil)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

