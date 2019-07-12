//
//  FriendPageViewController.swift
//  LineLA
//
//  Created by uscclab on 2018/11/6.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit
import UserNotifications

// Member attribute
class FriendPageViewController: UIViewController {
    var shared: GlobalInfo!
    var accountInfo: AccountInfo!
    var childFTVC: FriendTableViewController?
    var unReadNotification: MessageObserver!
    var databaseManager: DatabaseManager!
    var linphoneManager: LinphoneManager!
    var isNotification: (()->())!
    @IBOutlet weak var profileView: UIView! // unused TODO: profile information...
    @IBOutlet weak var imgViewAvatar: UIImageView!
    @IBOutlet weak var labelMemberName: UILabel!
}

// Override func
extension FriendPageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action:  #selector(swiped))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            self.childFTVC = controller
        }
     }
    
}

// My func
extension FriendPageViewController {
    func prepare() {
//        accountInfo = shared.accountInfo
//        imgViewAvatar.image = accountInfo.memberAvatar
//        labelMemberName.text = accountInfo.memberName
//        databaseManager = shared.databaseManager
//        linphoneManager = shared.linphoneManager
//        linphoneManager.login()
//        self.linphoneManager.theLinphone.controller = self
//        initClosure()
//        unReadNotification = MessageObserver(activity: isNotification, id: "Unread")
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
//        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
//        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func initClosure(){
//        isNotification = { () -> () in
//            let memberID = self.unReadNotification.memberID!
//            if memberID != self.accountInfo.memberID {
//                let date = self.shared.dateUtil
//                let msgID = self.unReadNotification.msgID!
//                let memberName = self.unReadNotification.memberName!
//                let msg = self.unReadNotification.msg!
//                let topicID = self.unReadNotification.topicID!
//                self.accountInfo.unReadCount = self.accountInfo.unReadCount! + 1
//                let unReadCount = self.accountInfo.unReadCount!
//
//                let content = UNMutableNotificationContent()
//                content.title = memberName
//                content.body = msg
//                content.badge = unReadCount as NSNumber
//                content.sound = UNNotificationSound.default
//                self.databaseManager.chatRoomTable.setTableName(topicID)
//                self.databaseManager.chatRoomTable.createTable()
//
//                let msgTime = date.getMsgTime()
//                self.databaseManager.chatRoomTable.insertData(_uuid: msgID, _memberId: memberID, _memberName: memberName, _memberAvatar: "", _msg: msg, _msgTime: msgTime)
//                //            let imageURL = Bundle.main.url(forResource: "pic", withExtension: "jpg")
//                //            let attachment = try! UNNotificationAttachment(identifier: "", url: imageURL!, options: nil)
//                //            content.attachments = [attachment]
//
//                //            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
//                let request = UNNotificationRequest(identifier: "notification1", content: content, trigger: nil)
//                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//            }
//        }
    }
    
    func exitUI() {
//        childFTVC?.tableViewData.FTVCData.removeAll()
//        childFTVC?.tableView.reloadData()
//        childFTVC?.exitUI()
//        childFTVC = nil
//        linphoneManager.logout()
//        linphoneManager = nil
        accountInfo = nil
        shared = nil
        imgViewAvatar.image = nil
        labelMemberName.text = nil
        profileView = nil
        imgViewAvatar = nil
        labelMemberName = nil
    }
}

// IBAction func
extension FriendPageViewController {
    @IBAction func logout(_ sender: Any) {
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
        print("friend logout")
    }
    
    @IBAction func addFriendBtnClick(_ sender: Any) {
        //test linphoneManager.idle
//        self.linphoneManager.idle()
    }
    
    @objc  func swiped(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if (self.tabBarController?.selectedIndex)! < 2
            { // set here  your total tabs
                if let controller = self.tabBarController?.viewControllers?[1] as? ChatPageViewController{
                    controller.shared = shared
                }
                self.tabBarController?.selectedIndex += 1
            }
        } else if gesture.direction == .right {
            if (self.tabBarController?.selectedIndex)! > 0 {
                self.tabBarController?.selectedIndex -= 1
            }
        }
    }
}
