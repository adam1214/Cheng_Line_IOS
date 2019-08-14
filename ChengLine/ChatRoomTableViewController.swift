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
    var messageObserver: MessageObserver!
    var indexPaths: [IndexPath]!
    var loadMsgbottom: Int!
    var loadMsgtop: Int!
    var MsgIndex: Int!
    var isLoadOver: Bool!
    var isFirstLoad: Bool!
    var showMsg: (() -> ())!
    var imageViewClick: ((_ img: UIImage) -> ())!
    @objc var endEditing: (() ->())!
    var currentInsInBottom = true
    var record_cnt: Int!
    var last_pk: Int!
    var cap: Int!
    
    @objc func youGotMessage(noti: Notification){
//        print("RecordImgBack")
        let tuple: tupleDict = (noti.userInfo?["RecordImgBack"] as! tupleDict)
        print("pos: \(tuple.num)")
        print("cnt: \(tableViewData.CRTVCData.count)")
        var index = 0
        for i in (0...tableViewData.CRTVCData.count - 1).reversed(){
            for j in (0...tableViewData.CRTVCData[i].mChatMsgCells.count - 1).reversed(){
                if index == tuple.num{
                    tableViewData.CRTVCData[i].mChatMsgCells[j].img = UIImage(data: tuple.data as Data)
                    tableView.reloadData()
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
        isFirstLoad = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "更新中...")
//        if isFirstLoad {
//            DispatchQueue.main.async {
//
//            }
//            isFirstLoad = false
//        }
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
//        let height = scrollView.bounds.height
//        let contentOffsetY = scrollView.contentOffset.y
//        let bottomOffset = scrollView.contentSize.height - contentOffsetY
//
//        if contentOffsetY == 0 {
//            if isLoadOver {
//                if loadMsgbottom > 0 {
//                    print("ok")
//                }
//            }
//        }
//
//        if bottomOffset <= height {
//            // 在最底部
//            print("在最底部")
//            self.currentInsInBottom = true
//        } else {
//            print("不在了")
//            self.currentInsInBottom = false
//        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
//            if /*ID == self.shared.accountInfo.memberID ||*/ self.currentInsInBottom {
//                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//            }
        
        
        
        
//        if currentInsInBottom && tableViewData.CRTVCData.count > 0 {
//            DispatchQueue.main.async {
//                let index = IndexPath(row: indexPath.row, section: indexPath.section) // use your index number or Indexpath
//            print("section: \(indexPath.section)")
//            print("row: \(indexPath.row)")
//                self.tableView.scrollToRow(at: indexPath,at: .bottom, animated: false) //here .middle is the scroll position can change it as per your need
//            }
//        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        // Configure the cell...
        print("indexPath.row: \(indexPath.row)")
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
        self.isLoadOver = true
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
        updata()
        self.tableView.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    func initTableViewData(){
//        let Arr = self.databasemanager.chatRoomTable.readData()
//        self.loadMsgtop = Arr.count
//        self.loadMsgbottom = loadMsgtop - 50
//        if self.loadMsgbottom <= 0 {
//            self.loadMsgbottom = 1
//        }
//        if self.loadMsgtop <= 1 {
//            self.isLoadOver = false
//        }
//        if self.isLoadOver {
//            let rowDataArr = Arr[self.loadMsgbottom..<self.loadMsgtop]
//            for row in rowDataArr {
//                var avatar: UIImage
//                if row.memberId == self.cRInfo.targetID { avatar = self.cRInfo.memberAvatar! }
//                else { avatar = self.cRInfo.targetAvatar! }
//                let chatMsgCell = ChatMsgCellInfo(msgID: row.uuid, avatar: avatar, ID: row.memberId, name: row.memberName, msg: row.msg, msgTime: row.msgTime)
//                self.addMsg(chatMsgCell: chatMsgCell)
//            }
//            self.loadMsgtop = self.loadMsgbottom
//            self.loadMsgbottom = self.loadMsgtop - 50
//            self.MsgIndex = self.tableViewData.CRTVCData[self.tableViewData.CRTVCData.count - 1].mChatMsgCells.count
//        }
    }
    
    func addMsg(chatMsgCell:ChatMsgCellInfo) {
        let date = self.shared.dateUtil
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
    
    func updata() {
//        if self.loadMsgbottom <= 0 {
//            self.loadMsgbottom = 1
//        }
//        if self.loadMsgtop <= 1 {
//            self.isLoadOver = false
//        }
//        if self.isLoadOver {
//            let Arr = self.databasemanager.chatRoomTable.readData()
//            let rowDataArr = Arr[self.loadMsgbottom..<self.loadMsgtop].reversed()
//            for row in rowDataArr {
//                let date = self.shared.dateUtil
//                var avatar: UIImage
//                if row.memberId == self.cRInfo.targetID { avatar = self.cRInfo.memberAvatar! }
//                else { avatar = self.cRInfo.targetAvatar! }
//                let chatMsgCell = ChatMsgCellInfo(msgID: row.uuid, avatar: avatar, ID: row.memberId, name: row.memberName, msg: row.msg, msgTime: row.msgTime)
//                let nextdate = date.getLocalDate(date: chatMsgCell.msgTime)
//                if self.tableViewData.CRTVCData[0].date != nextdate {
//                    self.tableViewData.CRTVCData.insert(DateCellInfo(date: date.getLocalDate(date: chatMsgCell.msgTime)), at: 0)
//                }
//                self.tableViewData.CRTVCData[0].mChatMsgCells.insert(chatMsgCell, at:0)
//            }
//            self.tableView.reloadData()
//            self.loadMsgtop = self.loadMsgbottom
//            self.loadMsgbottom = self.loadMsgtop - 50
//            self.MsgIndex = self.tableViewData.CRTVCData[self.tableViewData.CRTVCData.count - 1].mChatMsgCells.count
//        }
        
    }
    
    func initClosure(){
//        showMsg = {() -> () in
//            let date = self.shared.dateUtil
//            let msgID = self.messageObserver.msgID
//            let avatar = self.cRInfo.targetAvatar
//            let ID = self.messageObserver.memberID
//            let name = self.messageObserver.memberName //cRinfo.targetName
//            let msg = self.messageObserver.msg
//            let msgTime = date.getMsgTime()
//            let chatMsgCell = ChatMsgCellInfo(msgID: msgID, avatar: avatar, ID: ID, name: name, msg: msg, msgTime: msgTime)
//            self.databasemanager.chatRoomTable.insertData(_uuid: msgID!, _memberId: ID!, _memberName: name!, _memberAvatar: "", _msg: msg!, _msgTime: msgTime)
//            self.addMsg(chatMsgCell: chatMsgCell)
//            let CRTVCDatacount = self.tableViewData.CRTVCData.count
//            let mChatMsgCellscount = self.tableViewData.CRTVCData[CRTVCDatacount-1].mChatMsgCells.count
//            self.indexPaths.append(IndexPath(row: mChatMsgCellscount, section: CRTVCDatacount-1))
//            if mChatMsgCellscount == 1 {
//                self.tableView.reloadData()
//                self.indexPaths.removeAll()
//                let indexPath = IndexPath(row: mChatMsgCellscount, section: CRTVCDatacount-1)
//                if ID == self.shared.accountInfo.memberID || self.currentInsInBottom {
//                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
//                    self.currentInsInBottom = true
//                }
//            }
//            if #available(iOS 11, *) {
//                DispatchQueue.main.async {
//                    if self.indexPaths.count > 0{
//                        self.tableView.beginUpdates()
//                        self.tableView.insertRows(at: self.indexPaths, with: .none)
//                        self.indexPaths.removeAll()
//                        self.tableView.endUpdates()
//                        let indexPath = IndexPath(row: mChatMsgCellscount, section: CRTVCDatacount-1)
//                        if ID == self.shared.accountInfo.memberID || self.currentInsInBottom {
//                            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
//                            self.currentInsInBottom = true
//                        }
//                    }
//                }
//            } else{
//                self.tableView.beginUpdates()
//                self.tableView.insertRows(at: self.indexPaths, with: .none)
//                self.indexPaths.removeAll()
//                self.tableView.endUpdates()
//                let indexPath = IndexPath(row: mChatMsgCellscount, section: CRTVCDatacount-1)
//                if ID == self.shared.accountInfo.memberID || self.currentInsInBottom {
//                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
//                    self.currentInsInBottom = true
//                }
//            }
//        }
//
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
        roomInfo = nil
        showMsg = nil
        endEditing = nil
        messageObserver = nil
        tableViewData = nil
        shared = nil
        NotificationCenter.default.removeObserver(self, name: Notification.Name("RecordImgBack"), object: nil)
    }
    
    func setLastPK(pk: Int) {
        self.last_pk = pk
    }
}

extension UITableView{
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
