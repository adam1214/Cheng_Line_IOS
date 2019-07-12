//
//  AppDelegate.swift
//  LineLA
//
//  Created by uscclab on 2018/9/10.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit
import UserNotifications // Used local notification
//import AppCenter
//import AppCenterAnalytics
//import AppCenterCrashes
//import AppCenterDistribute
//import AppCenterPush

@UIApplicationMain

// Member attribute
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
}


extension AppDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //  Override point for customization after application launch.
//        MSAppCenter.start("36a5371f-1529-498e-8e2f-766db9167325", withServices: [
//            MSPush.self,
//            MSAnalytics.self,
//            MSCrashes.self
//        ])
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // 在程式一啟動即詢問使用者是否接受圖文(alert)、聲音(sound)、數字(badge)三種類型的通知 // 後續尚未撰寫
        center.requestAuthorization(options: [.alert,.sound,.badge, .carPlay], completionHandler: { (granted, error) in
            guard granted else { return }
            print("允許")
            center.getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        })
        
        UNUserNotificationCenter.current().delegate = self
        let shared = GlobalInfo.shared()
        shared.accountInfo.unReadCount = 10
        
        // TabBar items 變白色
        UITabBar.appearance().tintColor = UIColor.white
        LanuchScreen()
        return true
    }
    
    // LanuchScreen
    private func LanuchScreen(){
//        let lanuchScreenVC = UIStoryboard.init(name: "LaunchScreen", bundle: nil)
//        let rootVC = lanuchScreenVC.instantiateViewController(withIdentifier: "LaunchScreen")
//        self.window?.rootViewController = rootVC
//        self.window?.makeKeyAndVisible()
        // TO DO: readDBdata and init DB。 <---- func or call api
        isLogin()
//        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(isLogin), userInfo: nil, repeats: false)
    }
    
    // TO DO: modify the func name
    @objc func isLogin() {
        self.window = UIWindow()
        self.window?.makeKeyAndVisible()
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil)
        guard let rootVC = mainVC.instantiateViewController(withIdentifier: "NavRootController") as? NavRootController else { return }
        let shared = GlobalInfo.shared()
        if shared.loginInfo.token {
            if let TabBarVC = mainVC.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {
                print("duplicated login")
                if let childcontroller = TabBarVC.viewControllers?.first as? FriendPageViewController{
                    childcontroller.shared = shared
                }
                rootVC.viewControllers.append(TabBarVC)
            }
        } else {
            if let HomeVC = mainVC.instantiateViewController(withIdentifier: "HomeController") as? HomeController {
                HomeVC.shared = shared
                rootVC.viewControllers.append(HomeVC)
            }
        }
        self.window?.rootViewController = rootVC
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
//        var token = ""
//        for i in 0..<deviceToken.count {
//            token += String(format:"%002.2hhx", arguments: [devicimpeToken[i]])
//        }
//        
//        print("Token = \(token)")
        
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("進入背景1")
//        isBackground = true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("進入背景2")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("背景復活1")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("背景復活2")
//        let shared = GlobalInfo.shared()
//        shared.accountInfo.unReadCount = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// My func
extension AppDelegate {
    func prepare (){
        
    }
}
