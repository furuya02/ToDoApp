//
//  AppDelegate.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/04.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var deviceToken : String = ""
    var mainView : MainViewController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        mainView = self.window?.rootViewController as! MainViewController
        
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            let types = UIUserNotificationType.Alert
            let mySettings = UIUserNotificationSettings(forTypes:types, categories:nil)
            
            application.registerUserNotificationSettings(mySettings)
            application.registerForRemoteNotifications()
            
        } else{ //iOS7以前
            application.registerForRemoteNotificationTypes( UIRemoteNotificationType.Alert )
        }

        //バッチ非表示
        application.applicationIconBadgeNumber = 0
        return true
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {

        NSLog("ERROR " + error.localizedDescription)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let aps = userInfo["aps"] as? NSDictionary {
            if let objectId = aps["alert"] as? NSString {
                mainView.repository.integration(objectId as String) // 整合処理（１件のみ）
            }
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

        // デバイストークン取得
        self.deviceToken = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( NSCharacterSet(charactersInString: "<>" ))
            .stringByReplacingOccurrencesOfString(" ", withString: "") as String
        
        mainView.repository.installPush(self.deviceToken) // Push通知の登録
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        mainView.repository.uninstallPush() // Push通知の解除
    }

    func applicationWillEnterForeground(application: UIApplication) {
        mainView.repository.installPush(self.deviceToken) // Push通知の登録
        mainView.repository.integration() // 整合処理（全件）
    }

//    func applicationDidBecomeActive(application: UIApplication) {
//    }

//    func applicationWillTerminate(application: UIApplication) {
//
//    }

}

