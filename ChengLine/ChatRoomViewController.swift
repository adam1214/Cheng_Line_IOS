//
//  ChatRoomViewController.swift
//  LineLA
//
//  Created by uscclab on 2018/11/12.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit
import CocoaMQTT
import AVFoundation

// Member attribute
class ChatRoomViewController: UIViewController {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var labTitle: UILabel!
    @IBOutlet weak var textMsg: UITextView!
    @IBOutlet weak var textMsgView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var viewContainerView: UIView!
    var shared: GlobalInfo!
    var messageObserver: MessageObserver!
    var roomInfo: RoomInfo!
    var showMsg: (() -> ())!
    var keyboardObserver: KeyboardObserver!
    var setKeyboard: ((_ height: CGFloat) -> ())!
    var deviceOrientationObserver: DeviceOrientationObserver!
    var setdeviceOrientation: ((_ orientation: UIDeviceOrientation) -> ())!
    var gap: CGFloat!
    var textMsgMaxHight: CGFloat!
    var keyboardHeight: CGFloat!
    var textMsgViewBotton: NSLayoutConstraint!
    var ViewContainerViewTop: NSLayoutConstraint!
    var childCRTVC: ChatRoomTableViewController?
    var curorientation: UIDeviceOrientation!
    var isEditingTextMsg: Bool = false
    var viewHeigh: CGFloat!
    @IBOutlet weak var containerBotton: NSLayoutConstraint!
    
    @objc func youGotMessage(noti: Notification){
//         print("Got notification")
         shared = GlobalInfo.shared()
         if let record = (noti.userInfo?["record"]) as? String? ?? ""{
             print("record: \(record)")
             let splitLine = record.split(separator: "\r")
             if(childCRTVC?.record_cnt==1)
             {
                 for i in (0...splitLine.count-1).reversed() {
                    if i == 0{
                        childCRTVC?.setLastPK(pk: Int(String(splitLine[i]))!)
                    }else{
                        let sender = String(String(splitLine[i]).split(separator: "\t")[0])
                        let msg = String(String(splitLine[i]).split(separator: "\t")[1])
                        let time = String(String(splitLine[i]).split(separator: "\t")[2])
                        let data_str = String(String(splitLine[i]).split(separator: "\t")[3])
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date = dateFormatter.date(from: time)
                        var data_t: Int
                        var type: Int
                        var chatMsgCellInfo: ChatMsgCellInfo
                        if(sender != shared.mqttManager.clientID){
                            type = 0
                        }else{
                            type = 1
                        }
                        if(data_str == "text"){
                             data_t = 0
                             chatMsgCellInfo = ChatMsgCellInfo(avatar: shared.friendAvatarMap[sender], ID: sender, name: shared.aliasMap[sender], msg: msg, img: UIImage(named: "default_picMSG"), msgTime: date, type: type, data_t: data_t)
                        }else{
                             data_t = 1
                             chatMsgCellInfo = ChatMsgCellInfo(avatar: shared.friendAvatarMap[sender], ID: sender, name: shared.aliasMap[sender], msg: msg, img: UIImage(named: "default_picMSG"), msgTime: date, type: type, data_t: data_t)
                             //print("index:\(i-1)")
                             shared.mqttManager.mqtt.publish("IDF/RecordImgBack/\(shared.mqttManager.clientID!)/\(i-1)", withString: msg)
                        }
                        childCRTVC?.addMsg(chatMsgCell: chatMsgCellInfo)
                    }
                 }
            }
            else
            {
                for i in (0...splitLine.count-1) {
                    if i == 0{
                        childCRTVC?.setLastPK(pk: Int(String(splitLine[i]))!)
                    }else{
                        let sender = String(String(splitLine[i]).split(separator: "\t")[0])
                        let msg = String(String(splitLine[i]).split(separator: "\t")[1])
                        let time = String(String(splitLine[i]).split(separator: "\t")[2])
                        let data_str = String(String(splitLine[i]).split(separator: "\t")[3])
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date = dateFormatter.date(from: time)
                        var data_t: Int
                        var type: Int
                        var chatMsgCellInfo: ChatMsgCellInfo
                        if(sender != shared.mqttManager.clientID){
                            type = 0
                        }else{
                            type = 1
                        }
                        if(data_str == "text"){
                            data_t = 0
                            chatMsgCellInfo = ChatMsgCellInfo(avatar: shared.friendAvatarMap[sender], ID: sender, name: shared.aliasMap[sender], msg: msg, img: UIImage(named: "default_picMSG"), msgTime: date, type: type, data_t: data_t)
                        }else{
                            data_t = 1
                            chatMsgCellInfo = ChatMsgCellInfo(avatar: shared.friendAvatarMap[sender], ID: sender, name: shared.aliasMap[sender], msg: msg, img: UIImage(named: "default_picMSG"), msgTime: date, type: type, data_t: data_t)
                            //print("index:\(i-1)")
                            shared.mqttManager.mqtt.publish("IDF/RecordImgBack/\(shared.mqttManager.clientID!)/\((i-1) + 12 * (childCRTVC!.record_cnt-1))", withString: msg)
                        }
                        childCRTVC?.addMsg(chatMsgCell: chatMsgCellInfo)
                    }
                }
            }
         childCRTVC?.isLoading = false

         }else if let message = (noti.userInfo?["SendMessage"]) as? String? ?? ""{
//            print("recv: \(message)")
            let code = String(message.split(separator: "\t")[0])
            if code != roomInfo.code{
                return
            }else{
                let sender = String(message.split(separator: "\t")[1])
                let msg = String(message.split(separator: "\t")[2])
                let time = String(message.split(separator: "\t")[3])
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.date(from: time)
                let data_t: Int = 0
                var type: Int
                var chatMsgCellInfo: ChatMsgCellInfo
                if(sender != shared.mqttManager.clientID){
                    type = 0
                }else{
                    type = 1
                }
                chatMsgCellInfo = ChatMsgCellInfo(avatar: shared.friendAvatarMap[sender], ID: sender, name: shared.aliasMap[sender], msg: msg, img: UIImage(named: "default_picMSG"), msgTime: date, type: type, data_t: data_t)
                childCRTVC?.addMsg(chatMsgCell: chatMsgCellInfo)
            }
         }else if let sendImgDict = (noti.userInfo?["pic"]) as? SendImgDict {
            let image = UIImage(data: sendImgDict.data as Data)
            let sender = sendImgDict.sender
            let time = sendImgDict.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.date(from: time)
            var type: Int
            if(sender != shared.mqttManager.clientID){
                type = 0
            }else{
                type = 1
            }
            let chatMsgCell = ChatMsgCellInfo(avatar: shared.friendAvatarMap[sender], ID: sender, name: shared.aliasMap[sender], msg: "i_am_image", img: image, msgTime: date, type: type, data_t: 1)
            let date_pre = childCRTVC?.shared.dateUtil
            if childCRTVC?.tableViewData.CRTVCData.count == 0 {
                childCRTVC?.tableViewData.CRTVCData.append(DateCellInfo(date: (date_pre?.getLocalDate(date: chatMsgCell.msgTime))!))
            } else {
                let nextdate = date_pre?.getLocalDate(date: chatMsgCell.msgTime)
                if childCRTVC?.tableViewData.CRTVCData[childCRTVC!.tableViewData.CRTVCData.count-1].date != nextdate {
                    childCRTVC?.tableViewData.CRTVCData.append(DateCellInfo(date: (date_pre?.getLocalDate(date: chatMsgCell.msgTime))!))
                }
            }
            // add msg.
            childCRTVC?.tableViewData.CRTVCData[childCRTVC!.tableViewData.CRTVCData.count-1].mChatMsgCells.append(chatMsgCell)
            childCRTVC?.tableView.reloadData()
            childCRTVC?.tableView.scrollToBottom()
        }
    }
}

// Override func
extension ChatRoomViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        
        let notificationName = Notification.Name("UpdateMSG")
        NotificationCenter.default.addObserver(self, selector: #selector(youGotMessage(noti:)), name: notificationName, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if keyboardHeight != 0 {
            UITextView.animate(withDuration: 0.2, animations: {
                self.setTextMsgViewY(self.keyboardHeight)
                self.setTableViewHight()
                self.toTableViewLastCell()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // send data to Embed View. // ChatRoomViewController to ChatRoomTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedChatList" {
            let controller = segue.destination as! ChatRoomTableViewController
            controller.shared = shared
            controller.roomInfo = roomInfo
            controller.endEditing = { () -> () in
                self.view.endEditing(true)
                self.keyboardHeight = 0
                self.titleView.isHidden = false
                if self.curorientation != .portrait { self.setViewContainerViewY() }
            }
            self.childCRTVC = controller
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 鍵盤收起 (透過點擊背景)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.keyboardHeight = 0
        self.titleView.isHidden = false
        if self.curorientation != .portrait { self.setViewContainerViewY() }
    }
    
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
extension ChatRoomViewController: UITextViewDelegate {
    func prepare() {
        shared = GlobalInfo.shared()
        labTitle.text = roomInfo.roomName
        textMsg.delegate = self
        gap = 20
        textMsgMaxHight = 77
        keyboardHeight = 0
        initClosure()
        deviceOrientationObserver = DeviceOrientationObserver(activity: setdeviceOrientation)
//        self.messageObserver = MessageObserver(activity: showMsg, id: cRInfo.targetID!)
        self.keyboardObserver = KeyboardObserver(activity: setKeyboard)
        self.bgView.backgroundColor = UIColor(patternImage: UIImage(named: "bg_chatroom")!.imageFill(targetSize: self.view.bounds.size))
        // set textMsgView layout
        self.textMsgView.translatesAutoresizingMaskIntoConstraints = false
        textMsgViewBotton = self.textMsgView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        textMsgViewBotton.isActive = true
        // set viewContainerView layout
        self.viewContainerView.translatesAutoresizingMaskIntoConstraints = false
        ViewContainerViewTop = self.viewContainerView.topAnchor.constraint(equalTo: self.bgView.topAnchor, constant: 40)
        ViewContainerViewTop.isActive = true
        viewHeigh = self.view.frame.height
        
        self.curorientation = .portrait
        print("RoomName: \(roomInfo.roomName)")
    }
    
    func initClosure() {
        setKeyboard = { (_ height: CGFloat) -> () in
            if height != 0 { self.isEditingTextMsg = true }
            else { self.isEditingTextMsg = false}

            self.keyboardHeight = height
            // textView bottom  位在鍵盤頂部
            self.setTextMsgViewY(self.keyboardHeight)
            if self.curorientation != .portrait {
                self.titleView.isHidden = true
                self.setViewContainerViewY()
            }
            self.setTableViewHight()
            UITextView.animate(withDuration: 0.2, animations: { self.toTableViewLastCell() })
        }
        
        setdeviceOrientation = { (_ orientation: UIDeviceOrientation) -> () in
            var isAction = false
            if orientation != .portraitUpsideDown && orientation != .faceUp && orientation != .faceDown && orientation != .unknown {
                switch orientation {
                case .portrait:
                    if self.curorientation == orientation {
                        break
                    }
                    self.curorientation = orientation
                    self.gap = 20
                    self.titleView.isHidden = false
                    isAction = true
                    break
                case .portraitUpsideDown:
                    break
                case .landscapeRight:
                    if self.curorientation == orientation {
                        break
                    }
                    self.curorientation = orientation
                    self.gap = 0
                    if self.isEditingTextMsg { self.titleView.isHidden = true }
                    isAction = true
                    break
                case .landscapeLeft:
                    if self.curorientation == orientation {
                        break
                    }
                    self.curorientation = orientation
                    self.gap = 0
                    if self.isEditingTextMsg { self.titleView.isHidden = true }
                    isAction = true
                    break
                case .unknown:
                    break
                case .faceUp:
                    break
                case .faceDown:
                    break
                @unknown default:
                    fatalError()
                    break
                }
            }
            guard let img = UIImage(named: "bg_chatroom") else { return }
            self.bgView.backgroundColor = UIColor(patternImage: img.imageFill(targetSize: self.view.bounds.size))
            if isAction {
                self.setViewContainerViewY()
                self.setTextMsgViewY(0)
                self.toTableViewLastCell()
            }
        }
        
        showMsg = {() -> () in // TO DO: SQLite save msg.
//            DispatchQueue.main.async {
//                print("store msg...")
//            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textMsg.frame.width, height: .infinity)
        textView.isScrollEnabled = false
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if estimatedSize.height <= textMsgMaxHight {
                    constraint.constant = estimatedSize.height
                    setTextMsgViewHight(constraint.constant)
                    setTextMsgViewY(keyboardHeight)
                    setTableViewHight()
                } else {
                    constraint.constant = textMsgMaxHight
                }
            }
        }
        
        if estimatedSize.height >= textMsgMaxHight {
            textView.isScrollEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if setKeyboard != nil {
            setKeyboard(0)
        }
    }
    
    func setTextMsgViewHight(_ height: CGFloat){
        var frame = self.textMsgView.frame
        var textMsgHeight = height
        if height < 38 { textMsgHeight = 38 }
        frame.size.height = textMsgHeight + 8
        self.textMsg.frame.size.height = textMsgHeight
        self.textMsgView.frame = frame
    }
    
    func setTextMsgViewY(_ height: CGFloat) {
        var frame = self.textMsgView.frame
        frame.origin.y = (self.view.frame.height - self.gap - frame.height) - height
        self.textMsgView.frame = frame
        self.textMsgViewBotton.constant = -height
    }
    
    func setViewContainerViewY() {
        var y:CGFloat = 40
        if self.titleView.isHidden { y = 0 }
        var frame = self.viewContainerView.frame
        frame.origin.y = y
        frame.size.height = self.textMsgView.frame.origin.y - y
        self.viewContainerView.frame = frame
        self.ViewContainerViewTop.constant = y
    }
    
    func setTableViewHight() {
        var titleViewHeight = titleView.frame.height
        if self.titleView.isHidden { titleViewHeight = 0 }
        var TVframe = self.childCRTVC?.tableView.frame
        TVframe?.size.height = self.textMsgView.frame.origin.y - titleViewHeight
        self.childCRTVC?.tableView.frame = TVframe!
        self.viewContainerView.frame.size.height = (TVframe?.height)!
        if (self.childCRTVC?.tableView.contentSize.height)! >= (TVframe?.height)! && (self.childCRTVC?.currentInsInBottom)!{
            self.childCRTVC?.tableView.contentOffset.y = (self.childCRTVC?.tableView.contentSize.height)! - (TVframe?.height)!
        }
    }
    
    func toTableViewLastCell() { // if select cell is last cell then go to new last cell else nop.
        guard let mCRTVCDatacount = self.childCRTVC?.tableViewData.CRTVCData.count else { return }
        if (self.childCRTVC?.currentInsInBottom)! && mCRTVCDatacount > 0 {
            guard (self.childCRTVC?.tableViewData.CRTVCData[mCRTVCDatacount-1].mChatMsgCells.count) != nil else { return }
//            let indexPath = IndexPath(row: mChatMsgCellscount, section: mCRTVCDatacount-1)
//            self.childCRTVC?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func exitUI() {
        childCRTVC?.tableViewData.CRTVCData.removeAll()
        childCRTVC?.tableView.reloadData()
        childCRTVC?.exitUI()
        messageObserver = nil
        keyboardObserver = nil
        setdeviceOrientation = nil
        textMsgViewBotton = nil
        ViewContainerViewTop = nil
        showMsg = nil
        setKeyboard = nil
        setdeviceOrientation = nil
        deviceOrientationObserver = nil
        gap = nil
        textMsgMaxHight = nil
        keyboardHeight = nil
        curorientation = nil
    }
}

// IBAction func
extension ChatRoomViewController {
    @IBAction func back(_ sender: Any) {
        exitUI()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendMsg(_ sender: Any) {
        let message = textMsg.text!
        if message.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) != "" {
//            print("send:\(message)")
            let text = message.replacingOccurrences(of: "\t", with: "    ")
            let msg = roomInfo.code + "\t" + GlobalInfo.shared().mqttManager.clientID + "\t" + text
            GlobalInfo.shared().mqttManager.mqtt.publish("IDF/SendMessage/\(GlobalInfo.shared().mqttManager.clientID!)", withString: msg)
            textMsg.text = ""
        }
    }
    
    @IBAction func uploadBtnAction(_ sender: UIButton) {
        // 建立一個 UIImagePickerController 的實體
        let imagePickerController = UIImagePickerController()
        // 委任代理
        imagePickerController.delegate = self
        // 建立一個 UIAlertController 的實體
        // 設定 UIAlertController 的標題與樣式為 動作清單 (actionSheet)
        let imagePickerAlertController = UIAlertController(title: "上傳圖片", message: "請選擇要上傳的圖片", preferredStyle: .actionSheet)
        // 建立三個 UIAlertAction 的實體
        // 新增 UIAlertAction 在 UIAlertController actionSheet 的 動作 (action) 與標題
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { (Void) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.photoLibrary)，並 present UIImagePickerController
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { (Void) in
            
            // 判斷是否可以從相機取得照片來源
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.camera)，並 present UIImagePickerController
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        // 新增一個取消動作，讓使用者可以跳出 UIAlertController
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (Void) in
            
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        
        // 將上面三個 UIAlertAction 動作加入 UIAlertController
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        // 當使用者按下 uploadBtnAction 時會 present 剛剛建立好的三個 UIAlertAction 動作與
        present(imagePickerAlertController, animated: true, completion: nil)
    }
}

extension ChatRoomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
            self.dismiss(animated: true, completion: {
            var img:UIImage? = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            if picker.allowsEditing {
                img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            }
                
                DispatchQueue.main.async {
                    let sender = GlobalInfo.shared().mqttManager.clientID
                    let message = CocoaMQTTMessage(topic: "IDF/SendImg/\(sender!)/\(self.roomInfo.code)", payload: [UInt8](((img?.resizedToHundred()?.jpegData(compressionQuality: 1))!)), qos: CocoaMQTTQOS.qos2, retained: false, dup: false)
                    GlobalInfo.shared().mqttManager.mqtt.publish(message)
//                    print("size: \(img?.resizedToHundred()?.pngData()?.count)")
                }
        })
    }
}


extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedToHundred() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > 1000 { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                let imageData = resizedImage.pngData()
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        }
        
        return resizingImage
    }
}
