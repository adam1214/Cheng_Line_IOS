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
    
    @objc func youGotMessage(noti: Notification){
//        print("Got notification")
//        print((noti.userInfo?["name"])!)
        let str = (noti.userInfo?["name"])! as? String ?? ""
        if str == "TabChat"{
            print(str)
            if let controller = self.tabBarController?.viewControllers?[1] as? ChatPageViewController{
                controller.shared = shared
            }
        }
    }
    
    @objc func msgFromMQTT(noti: Notification){
        if let name = (noti.userInfo?["name"]) as? String? ?? ""{
//            print("AAAAAA")
            labelMemberName.text = name
            print("ChangeName: \(name)")
        }else if let init_msg = (noti.userInfo?["init"]) as? String? ?? ""{
            let init_msg_splitLine = init_msg.components(separatedBy: "\r")
            for room in init_msg_splitLine{
//                print(room)
                let code = String(room.split(separator: "\t")[0])
                let roomName = String(room.split(separator: "\t")[1])
                let type = String(room.split(separator: "\t")[3])
                let rMsg = String(room.split(separator: "\t")[4])
                let rMsgdate = String(room.split(separator: "\t")[5])
                var memberID : String = ""
                if type == "F"{
                    let member_str = String(room.split(separator: "\t")[2])
                    let member_list = member_str.components(separatedBy: "-")
                    for member in member_list{
                        if member != UserDefaults.LoginInfo.string(forKey: .cardID){
                            shared.aliasMap.updateValue(roomName, forKey: member)
                            memberID = member
//                            print("Member:\(member)")
                        }
                    }
                }
                else{
                    memberID = ""
                }
                let roomInfo = RoomInfo(code: code,ID: memberID ,roomName: roomName, type: type, rMsg: rMsg, rMsgDate: rMsgdate)
                shared.roomlist.append(roomInfo)
            }
            let roomlist = shared.roomlist
            for room in roomlist{
                if(room.type == "F"){
                    let profile = ProfileInfo(profileName: room.roomName, section: 1, chatRoomID: room.code, avatar: UIImage(named: "image"), phoneNb: "1234")
                    shared.mTVCDataManager.FTVCData[1].ProfileInfos.append(profile)
                    let tachiba : String = "0"
                    let action : String = "Init"
                    let MSG : String = "\(action):\(room.ID)"
                    shared.mqttManager.mqtt.publish("IDF/FriendIcon/\(shared.mqttManager.clientID!)", withString: MSG)
                }
                else if(room.type == "G"){
                    let profile = ProfileInfo(profileName: room.roomName, section: 0, chatRoomID: room.code, avatar: UIImage(named: "image"), phoneNb: "1234")
                    shared.mTVCDataManager.FTVCData[0].ProfileInfos.append(profile)
                    //                        self.tableViewData.FTVCData[0].ProfileInfos.append(profile)
                }
                else{
                    break
                }
            }
            let FTVCDatacount = shared.mTVCDataManager.FTVCData.count
            let ProfileInfoscount = shared.mTVCDataManager.FTVCData[FTVCDatacount-1].ProfileInfos.count
            self.childFTVC?.indexPaths.append(IndexPath(row: ProfileInfoscount, section: FTVCDatacount-1))
            self.childFTVC?.tableView.reloadData()
            
        }else if let icon = (noti.userInfo?["icon"]) as? NSData?{
            if(icon == nil){
                print("null")
            }
            let image = UIImage(data: icon! as Data)
            imgViewAvatar.image = image
            imgViewAvatar.layer.borderWidth = 1
            imgViewAvatar.layer.borderColor =  UIColor.black.cgColor
            imgViewAvatar.layer.cornerRadius = imgViewAvatar.frame.height/2
            imgViewAvatar.clipsToBounds = true
            print("ID: \(shared.mqttManager.clientID!)")
            shared.mqttManager.mqtt.publish("IDF/Initialize/\(shared.mqttManager.clientID!)", withString: "")
        }
    }
    @objc func fIconMessage(noti: Notification){
        let studentID = (noti.userInfo?["ficon"]) as? String? ?? ""
        for index in 1...shared.roomlist.count{
            if shared.roomlist[index-1].ID == studentID{
                shared.mTVCDataManager.FTVCData[1].ProfileInfos[index-1].avatar = shared.roomlist[index-1].icon
            }
        }
//        if(room.type == "F"){
//            let profile = ProfileInfo(profileName: room.roomName, section: 1, chatRoomID: room.code, avatar: UIImage(named: "image"), phoneNb: "1234")
//            shared.mTVCDataManager.FTVCData[1].ProfileInfos.append(profile)
//            let tachiba : String = "0"
//            let action : String = "Init"
//            let MSG : String = "\(action):\(room.ID)"
//            shared.mqttManager.mqtt.publish("IDF/FriendIcon/\(shared.mqttManager.clientID!)", withString: MSG)
//        }
        self.childFTVC?.tableView.reloadData()
    }
}

// Override func
extension FriendPageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action:  #selector(swiped))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let notificationName = Notification.Name("NotifiacationTabClick")
        let notificationNameMQTT = Notification.Name("NotificationMQTT")
        let notificationFIcon = Notification.Name("NotificationFIcon")
        NotificationCenter.default.addObserver(self, selector: #selector(youGotMessage(noti:)), name: notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(msgFromMQTT(noti:)), name: notificationNameMQTT, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fIconMessage(noti:)), name: notificationFIcon, object: nil)
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
          shared.mqttManager.setupMQTT(num: 1)
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
        childFTVC?.tableViewData.FTVCData.removeAll()
        childFTVC?.tableView.reloadData()
        childFTVC?.exitUI()
        childFTVC = nil
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


