//
//  ChatRoomTableViewController.swift
//  LineLA
//
//  Created by uscclab on 2018/11/20.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit
import SQLite3
import SQLite

// Member attribute
class ChatRoomTableViewController: UITableViewController {
    var shared: GlobalInfo!
    var mqttManager: MQTTManager!
    var roomInfo: RoomInfo!
    var tableViewData: TVCDataManager!
    var indexPaths: [IndexPath]!
    var imageViewClick: ((_ img: UIImage) -> ())!
    @objc var endEditing: (() ->())!
    var currentInsInBottom = true
    var record_cnt: Int!
    var last_pk: Int!
    var cap: Int!
    var isReachingEnd: Bool!
    var isLoading: Bool!
    
    @objc func youGotMessage(noti: Notification){
        print("RecordImgBack")
        let tuple: TupleDict = (noti.userInfo?["RecordImgBack"] as! TupleDict)
//        print("pos: \(tuple.num)")
//        print("cnt: \(tableViewData.CRTVCData.count)")
        var index = 0
        for i in (0...tableViewData.CRTVCData.count - 1).reversed(){
            for j in (0...tableViewData.CRTVCData[i].mChatMsgCells.count - 1).reversed(){
                if index == tuple.num{
                    tableViewData.CRTVCData[i].mChatMsgCells[j].img = UIImage(data: tuple.data as Data)
                    tableView.reloadData()
                    if isReachingEnd != true && self.record_cnt == 1{
                        tableView.scrollToBottom()
                    }
                    return
                }
                index = index + 1
            }
        }
    }
    
}

// Override func
extension ChatRoomTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "更新中...")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        print("\(tableViewData.CRTVCData.count)")
        return tableViewData.CRTVCData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableViewData.CRTVCData[section].mChatMsgCells.count != 0 {
            return tableViewData.CRTVCData[section].mChatMsgCells.count + 1
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isReachingEnd = scrollView.contentOffset.y >= 0
            && scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        // Configure the cell...
//        print("indexPath.row: \(indexPath.row)")
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell") as? ChatRoomDataTableViewCell else {
                return UITableViewCell()
            }
            cell.dateCell = tableViewData.CRTVCData[indexPath.section]
            cell.updateUI()
            return cell
        } else  {
            let dataIndex = indexPath.row - 1
            let ID = tableViewData.CRTVCData[indexPath.section].mChatMsgCells[dataIndex].ID
            if ID == shared.mqttManager.clientID {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "RightMsgCell") as? ChatRightMessageTableViewCell else {
                    return UITableViewCell()
                }
                cell.chatMsgCell = tableViewData.CRTVCData[indexPath.section].mChatMsgCells[dataIndex]
                cell.updateUI(imageViewClick)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeftMsgCell") as? ChatLeftMessageTableViewCell else {
                    return UITableViewCell()
                }
                cell.chatMsgCell = tableViewData.CRTVCData[indexPath.section].mChatMsgCells[dataIndex]
                cell.updateUI(imageViewClick)
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.endEditing() // keyboard
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
extension ChatRoomTableViewController {
    func prepare() {
        // keyboard
//        tableView.keyboardDismissMode = .interactive
        mqttManager = shared.mqttManager
        tableViewData = shared.mTVCDataManager
        self.cap = 12
        self.record_cnt = 0
        self.last_pk = 0
        self.isLoading = false
        self.indexPaths = [IndexPath]()
        initTableViewData()
        initClosure()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
//        self.messageObserver = MessageObserver(activity: showMsg, id: cRInfo.targetID)
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        record_cnt = record_cnt + 1
        let msg = roomInfo.code + "\t" + String(record_cnt) + "\t" + String(last_pk)
        mqttManager.mqtt.publish("IDF/GetRecord/\(mqttManager.clientID!)", withString: msg)
        
        let notificationName = Notification.Name("RecordImgBack")
        NotificationCenter.default.addObserver(self, selector: #selector(youGotMessage(noti:)), name: notificationName, object: nil)
    }
    
    @objc func handleRefresh(){
        self.tableView.refreshControl?.endRefreshing()
        if isLoading == false{
            updata()
            self.tableView.reloadData()
        }
    }
    
    func initTableViewData(){
    }
    
    func addMsg(chatMsgCell:ChatMsgCellInfo) {
        let date = self.shared.dateUtil
        if(record_cnt==1)
        {
            if self.tableViewData.CRTVCData.count == 0 {
                self.tableViewData.CRTVCData.append(DateCellInfo(date: date.getLocalDate(date: chatMsgCell.msgTime)))
            } else {
                let nextdate = date.getLocalDate(date: chatMsgCell.msgTime)
                if self.tableViewData.CRTVCData[self.tableViewData.CRTVCData.count-1].date != nextdate {
                    self.tableViewData.CRTVCData.append(DateCellInfo(date: date.getLocalDate(date: chatMsgCell.msgTime)))
                }
            }
            // add msg.
            self.tableViewData.CRTVCData[self.tableViewData.CRTVCData.count-1].mChatMsgCells.append(chatMsgCell)
            self.tableView.reloadData()
            self.tableView.scrollToBottom()
        }
        else
        {
            let pre_date = date.getLocalDate(date: chatMsgCell.msgTime)
            if self.tableViewData.CRTVCData[0].date != pre_date
            {
                self.tableViewData.CRTVCData.insert(DateCellInfo(date: date.getLocalDate(date: chatMsgCell.msgTime)), at: 0)
            }
            // add msg.
            self.tableViewData.CRTVCData[0].mChatMsgCells.insert(chatMsgCell,at: 0)
            self.tableView.reloadData()
        }
    }
    
    func updata() {
        isLoading = true
        record_cnt = record_cnt + 1
        let msg: String = roomInfo.code + "\t" + String(record_cnt) + "\t" + String(last_pk)
        GlobalInfo.shared().mqttManager.mqtt.publish("IDF/GetRecord/\(mqttManager.clientID!)", withString: msg)
        print("UPDATE")
    }
    
    func initClosure(){
        imageViewClick = {(_ img: UIImage) -> () in
            //      cell.isPresent = false
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "ShowImageViewController") as? ShowImageViewController {
                controller.image = img
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func exitUI() {
        for var cd in tableViewData.CRTVCData{
            cd.mChatMsgCells.removeAll()
        }
        tableViewData.CRTVCData.removeAll()
        endEditing = nil
        tableViewData = nil
        NotificationCenter.default.removeObserver(self, name: Notification.Name("RecordImgBack"), object: nil)
    }
    
    func setLastPK(pk: Int) {
        self.last_pk = pk
    }
}

extension UITableView{
    func scrollToBottom(){
        DispatchQueue.main.async {
            let sections = self.numberOfSections
            let rows = self.numberOfRows(inSection: sections - 1)
            if (rows > 0){
                self.scrollToRow(at: NSIndexPath(row: rows - 1, section: sections - 1) as IndexPath, at: .bottom, animated: true)
            }
        }
    }
}
