//
//  FriendTableViewController.swift
//  LineLA
//
//  Created by uscclab on 2018/10/22.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit

// Member attribute
class FriendTableViewController: UITableViewController {
//    var accountInfo = GlobalInfo.shared().accountInfo
    var shared: GlobalInfo!
    var mqttManager: MQTTManager!
    var accountInfo: AccountInfo!
    var memberID: String?
    var indexPaths: [IndexPath]!
    var tableViewData: TVCDataManager!
    var updataAppInfo: ((_ responseData: Data) -> ())!
    var gotoCallController: ((ProfileInfo) -> ())!
}

// Override func
extension FriendTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        print("load data")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mqttManager = shared.mqttManager
        memberID = shared.accountInfo.memberID
        tableViewData = shared.mTVCDataManager
        self.refreshControl?.attributedTitle = NSAttributedString(string: "更新中...")
//        print("again")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        print("delete cell.")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tableViewData.FTVCData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableViewData.FTVCData[section].open == true{
            return tableViewData.FTVCData[section].ProfileInfos.count + 1
        }
        else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "classLabel") as? TypeTableViewCell else {
                return UITableViewCell()
            }
            cell.type = tableViewData.FTVCData[indexPath.section]//.type
            cell.updateUI()
            return cell
        } else {
            // Use different cell  identifier if needed
            let dataIndex = indexPath.row - 1
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "profileItem") as? FriendTableViewCell else {
                return UITableViewCell()
            }
            cell.profile = tableViewData.FTVCData[indexPath.section].ProfileInfos[dataIndex]//.profile
            cell.updateUI(gotoCallController)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { // open classcell or close classcell
            tableViewData.FTVCData[indexPath.section].open = !tableViewData.FTVCData[indexPath.section].open
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
        } else { // to be modified...   // TO DO: type A, type B, type C.
            let dataIndex = indexPath.row - 1
            let profile = tableViewData.FTVCData[indexPath.section].ProfileInfos[dataIndex]//.profile!
            if let controller = storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController{   // this is go to fried chatroom.
                mqttManager.curtopic = profile.chatRoomID
                controller.shared = shared
                controller.cRInfo = ChatRoomInfo(memberAvatar: accountInfo.memberAvatar, memberName: accountInfo.memberName, memberID: accountInfo.memberID, targetAvatar: profile.avatar, targetName: profile.profileName, targetID: profile.chatRoomID, chatRoomTitle: profile.profileName, type: profile.section)
//                if let parentController = self.parent as? FriendTableViewController {
//                    parentController.exitUI()
//                }
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

// My func
extension FriendTableViewController {
    func prepare() {
        tableViewData = shared.mTVCDataManager
        mqttManager = shared.mqttManager
        memberID = shared.accountInfo.memberID
        accountInfo = shared.accountInfo
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.indexPaths = [IndexPath]()
        initTableViewData()
        initClosure()
        GlobalInfo.getRelation(memberID: memberID, activity: updataAppInfo)
        
        
        sleep(3)
        DispatchQueue.main.async {
            self.tableViewData.FTVCData[0].open = true
            self.tableViewData.FTVCData[1].open = true
            self.tableViewData.FTVCData[2].open = true
            self.tableViewData.FTVCData[3].open = true
            self.tableView.reloadData()
        }
    }
    
    @objc func handleRefresh(){
//        updata()
        self.tableView.refreshControl?.endRefreshing()
        //        self.tableView.reloadData()
    }
    
    func initTableViewData() {
        tableViewData.FTVCData.append(TypeInfo(typeLabelText: "\(NSLocalizedString("gorup:typeA",comment: ""))"))
        tableViewData.FTVCData.append(TypeInfo(typeLabelText: "\(NSLocalizedString("gorup:typeB",comment: ""))"))
        tableViewData.FTVCData.append(TypeInfo(typeLabelText: "\(NSLocalizedString("gorup:typeC",comment: ""))"))
        tableViewData.FTVCData.append(TypeInfo(typeLabelText: "\(NSLocalizedString("friend",comment: ""))"))
    }
    
    func initClosure(){
        updataAppInfo = {(_ responseData: Data) -> () in
            // parse the result as JSON, since that's what the API provides
            do {
                for i in 0..<self.tableViewData.FTVCData.count {
                    self.tableViewData.FTVCData[i].ProfileInfos.removeAll()
                }
                
                // get jsonAry from responseData [[]]
                guard let jsonAry = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String:String]] else { return } // print("Could not get array from Data")
                
                for index in 0..<jsonAry.count { // get jsonObject from jsonAry.
                    let jsonObject = jsonAry[index]
                    
                    guard let profileName = jsonObject["name"] else { return } //print("Could not get name from JSON")
                    guard let section = Int(jsonObject["section"]!) else { return } // print("Could not get section from JSON")
                    guard let chatRoomID = jsonObject["chatRoomID"] else { return } // print("Could not get chatRoomID from JSON")
                    guard let data = Data(base64Encoded: jsonObject["avatar"]!) else { return } // print("Could not get avater from JSON")
                    var phoneNb = ""
                    if let phoneNumber = jsonObject["friendID"] { phoneNb = phoneNumber } //print("Could not get friendID from JSPN")
                    guard let memberID = self.memberID else { return }
                    
                    var topicName = ""
                    switch chatRoomID{
                    case "group_3":
                        topicName = "group_3/\(memberID)"
                    case "group_5":
                        topicName = "recommend/\(memberID)"
                    case "group_6":
                        topicName = "support/\(memberID)"
                    default:
                        topicName = chatRoomID
                    }
                    
                    let avatar = UIImage(data: data,scale:1.0)
                    var profile:ProfileInfo
                        
                    profile = ProfileInfo(profileName: profileName,  section: section, chatRoomID: topicName, avatar: avatar, phoneNb: phoneNb)
                    
                    self.tableViewData.FTVCData[section].ProfileInfos.append(profile)
                    let FTVCDatacount = self.tableViewData.FTVCData.count
                    let ProfileInfoscount = self.tableViewData.FTVCData[FTVCDatacount-1].ProfileInfos.count
                    self.indexPaths.append(IndexPath(row: ProfileInfoscount, section: FTVCDatacount-1))
                    if !(self.mqttManager.topicList.contains(topicName: topicName)) { self.mqttManager.topicList.append(topicName: topicName) }
                    
                }
                self.mqttManager.setupMQTT()
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        gotoCallController = { (_ profile:ProfileInfo) -> () in
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "CallViewController") as? CallViewController {
                controller.shared = self.shared
                controller.profile = profile
                controller.isCallOut = true
                self.present(controller, animated: true, completion: nil)
            }
        }
    }	
    
    func exitUI(){
        self.memberID = nil
        self.mqttManager = nil
        self.tableViewData = nil
        self.updataAppInfo = nil
        self.accountInfo = nil
        self.shared = nil
    }
}
