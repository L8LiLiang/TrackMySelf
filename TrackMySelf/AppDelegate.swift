//
//  AppDelegate.swift
//  TrackMySelf
//
//  Created by Chuanxun on 16/3/28.
//  Copyright © 2016年 Leon. All rights reserved.
//

//https://developer.apple.com/library/ios/samplecode/Regions/Introduction/Intro.html

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Bmob.registerWithAppKey("2e9839a30efeff9b35a56432a0039c80")
        
        if #available(iOS 8.0, *) {
            let type:UIUserNotificationType = [UIUserNotificationType.Badge,UIUserNotificationType.Badge,UIUserNotificationType.Sound]
            let notificationSetting = UIUserNotificationSettings(forTypes: type, categories: nil)
            
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSetting)
        } else {
            // Fallback on earlier versions
//                    [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
            let type:UIRemoteNotificationType = [UIRemoteNotificationType.Alert,UIRemoteNotificationType.Badge,UIRemoteNotificationType.Sound]
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(type)
        }

        
        self.makeNotification("AppLaunch")
        
        return true
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


    func makeNotification(desc:String){
        let notify = UILocalNotification()
        notify.alertBody = desc
        UIApplication.sharedApplication().presentLocalNotificationNow(notify)
    }
    
}

