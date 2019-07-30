//
//  ChatPageViewController.swift
//  LineLA
//
//  Created by uscclab on 2018/11/6.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit

// unused
// Member attribute
class ChatPageViewController: UIViewController {
//    let appDeleagte = UIApplication.shared.delegate as! AppDelegate
    var shared: GlobalInfo!
    var imgAvatar: UIImage?
    var memberName: String?
    var memberID: String?
    
    @objc func youGotMessage(noti: Notification){
//        print("Got notification")
//        print((noti.userInfo?["name"])!)
        let str = (noti.userInfo?["name"])! as? String ?? ""
        if str == "TabFriend"{
            print(str)
            if let controller = self.tabBarController?.viewControllers?[0] as? FriendPageViewController{
                controller.shared = shared
            }
        }
    }
}

// Override func
extension ChatPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(swiped))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        // Do any additional setup after loading the view.
        
        let notificationName = Notification.Name("NotifiacationTabClick")
        NotificationCenter.default.addObserver(self, selector: #selector(youGotMessage(noti:)), name: notificationName, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "EmbedFriendList" {
         let controller = segue.destination as! FriendTableViewController
         controller.shared = shared
        }
    }
}

// My func
extension ChatPageViewController {
    func prepare() {
//        accountInfo = shared.accountInfo
//        if let memberAvatar = accountInfo.memberAvatar { self.memberAvatar = memberAvatar.toCircle() }
//        if let memberName = accountInfo.memberName { self.memberName = memberName }
//        imgViewAvatar.image = memberAvatar
//        labelMemberName.text = memberName
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
//        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func exitUI() {
        shared = nil
        imgAvatar = nil
        memberName = nil
        memberID = nil
    }
}

// IBAction func
extension ChatPageViewController {
    @IBAction func logout(_ sender: Any) {
//        for i in 0..<(self.navigationController?.viewControllers.count)!{
//            if let controller =  self.navigationController?.viewControllers[i] as? HomeController {
//                shared.clearAppInfo()
//                controller.shared = shared
//                controller.accountInfo = shared.accountInfo
//                controller.loginInfo = shared.loginInfo
//                exitUI()
//                if let controller = self.tabBarController?.viewControllers?[0] as? FriendPageViewController{
//                    controller.exitUI()
//                }
//                self.navigationController?.popToViewController(controller, animated: true)
//                break
//            }
//        }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let controller = appDelegate.window?.rootViewController as? NavRootController {
                controller.viewControllers.removeAll()
                let mainVC = UIStoryboard.init(name: "Main", bundle: nil)
                if let childcontroller = mainVC.instantiateViewController(withIdentifier: "HomeController") as? HomeController {
                    shared.clearAppInfo()
                    childcontroller.shared = shared
                    exitUI()
                    controller.viewControllers.append(childcontroller)
                }
            }
        }
        print("chat logout")
    }
    
    @objc  func swiped(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if (self.tabBarController?.selectedIndex)! < 2
            { // set here  your total tabs
                self.tabBarController?.selectedIndex += 1
            }
        } else if gesture.direction == .right {
            if (self.tabBarController?.selectedIndex)! > 0 {
                if let controller = self.tabBarController?.viewControllers?[0] as? FriendPageViewController{
                    controller.shared = shared
                }
                self.tabBarController?.selectedIndex -= 1
            }
        }
    }
}
