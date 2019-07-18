//
//  TabBarViewController.swift
//  LineLA
//
//  Created by uscclab on 2018/11/6.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit

// Member attribute
class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
}

// Override func
extension TabBarViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.delegate = self
    }
    
    // 選轉
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // event onclick
        let notificationName = Notification.Name("NotifiacationTabClick")
        if item.tag == 0 {
//             print("Click TabFriend")
             let testname = Notification.Name("NotificationMQTT")
            NotificationCenter.default.post(name: testname, object: nil)
             let nameDict:[String: String] = ["name": "TabFriend"]
             NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nameDict)
        }else if item.tag == 1{
//             print("Click TabChat")
             let nameDict:[String: String] = ["name": "TabChat"]
             NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nameDict)
        }
    }
}

//
extension TabBarViewController {
    // below code create swipe gestures function
    // MARK: - swiped
}
