//
//  ChatTableViewController.swift
//  LineLA
//
//  Created by uscclab on 2018/10/22.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit

// unused.
// Member attribute
class ChatTableViewController: UITableViewController {
    let appDeleagte = UIApplication.shared.delegate as! AppDelegate
    var memberID: String?
    var imgAvatar: UIImage?
    var memberName: String?
    var tableViewData: TVCDataManager!
    var chatList = [RoomInfo]()
    
//    var tableViewData: [TypeTableViewCell]!
}

// Override func
extension ChatTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChatList()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
//        var dataIndex = indexPath.row - 1
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatItem") as? ChatTableViewCell else {
                return UITableViewCell()
            }
            cell.roomInfo = chatList[indexPath.row]
            cell.updateUI()
            return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == 0 {
//            if tableViewData[indexPath.section].open == true{
//                tableViewData[indexPath.section].open = false
//                let sections = IndexSet.init(integer: indexPath.section)
//                tableView.reloadSections(sections, with: .none)
//            } else {
//                tableViewData[indexPath.section].open = true
//                let sections = IndexSet.init(integer: indexPath.section)
//                tableView.reloadSections(sections, with: .none)
//            }
//
//        }
//        let profile = tableViewData.FTVCData[indexPath.section].ProfileInfos[dataIndex]//.profile!
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController{   // this is go to fried chatroom.
            controller.shared = GlobalInfo.shared()
            controller.roomInfo = GlobalInfo.shared().roomlist[indexPath.row]
            //                if let parentController = self.parent as? FriendTableViewController {
            //                    parentController.exitUI()
            //                }
            navigationController?.pushViewController(controller, animated: true)
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
extension ChatTableViewController {
    func prepare() {
//        tableViewData = []
//        if let imgAvatar = appDeleagte.imgAvatar {
//            self.imgAvatar = imgAvatar
//        }
//        if let memberName = appDeleagte.memberName {
//            self.memberName = memberName
//        }
//        if let memberID = appDeleagte.memberID {
//            self.memberName = memberID
//        }
    }
    
    func updateChatList(){
        GlobalInfo.shared().roomlist.sort(by: {$0.rMsgDate > $1.rMsgDate})
        chatList = GlobalInfo.shared().roomlist
        print("count:\(chatList.count)")
    }
}
