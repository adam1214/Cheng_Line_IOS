//
//  MQTTManager.swift
//  LineLA
//
//  Created by uscclab on 2018/11/13.
//  Copyright © 2018 uscclab. All rights reserved.
//

import Foundation
import CocoaMQTT

// Member attribute
class MQTTManager: NSObject{
    let USERNAME = "ChengLine"
    let PASSWORD = "ChengLine"
    var uuID: String! // UUID
    var clientID: String!
    var mqtt: CocoaMQTT!
    var timing: Int!
    
    private static var mqttManager: MQTTManager = {
        return MQTTManager()
    }()
    
    private override init(){
        super.init()
        
        uuID = "CocoaMQTT-" + String(UUID().uuidString)
        mqtt = CocoaMQTT(clientID: uuID, host: "140.116.82.52", port: 1883)
        
        mqtt.username = USERNAME
        mqtt.password = PASSWORD
        
        mqtt.keepAlive = 60
        mqtt.delegate = self
        
    }

    class func shared() -> MQTTManager {
        return mqttManager
    }
    
    func subTopicLogin(){
        mqtt.subscribe("IDF/Login/\(uuID!)/Re", qos: CocoaMQTTQOS.qos2)
    }
    
    func subTopicMain(){
        mqtt.subscribe("IDF/+/\(clientID!)/Re", qos: CocoaMQTTQOS.qos2)
        mqtt.subscribe("IDF/SendImg/\(clientID!)/+/+/+/Re", qos: CocoaMQTTQOS.qos2)
        mqtt.subscribe("IDF/RecordImgBack/\(clientID!)/+/Re", qos: CocoaMQTTQOS.qos2)
//        mqtt.subscribe("IDF/FriendIcon/\(clientID!)/+/Re",qos:CocoaMQTTQOS.qos2)
    }
    
    func unsubTopicLogin(){
        mqtt.unsubscribe("IDF/Login/\(uuID!)/Re")
    }
    
    func unsubTopicMain(){

    }
    
}

// MQTTManager: CocoaMQTTDelegate
extension MQTTManager: CocoaMQTTDelegate {
    // Optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
//        print("trust: \(trust)")
        /// Validate the server certificate
        ///
        /// Some custom validation...
        ///
        /// if validatePassed {
        ///     completionHandler(true)
        /// } else {
        ///     completionHandler(false)
        /// }
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
//        print("ack: \(ack)")
        
        if ack == .accept {
            print("connect accept")
            if timing == 0{
                subTopicLogin()
            }else if timing == 1{ //duplicate login
                subTopicMain()
                mqtt.publish("IDF/GetUserData/\(clientID!)", withString: "")
            }else if timing == 2{
                subTopicMain()
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        print("new state: \(state)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
//        print("publish message: \(String(describing: message.string?.description)), id: \(id)")
          print("send topic: \(message.topic)\tsend msg: \(String((message.string!)))")
//        print("send msg \(String((message.string!)))")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
//        print("id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
//        print("recv message: \(String(describing: message.string?.description)), id: \(id)")
//          let msg = String(message.string!)
          let topic = String(message.topic)
          let idf = topic.split(separator: "/")
          let notificationNameMQTT = Notification.Name("NotificationMQTT")
        print("IDF:\(idf[1])")
//          print("recv msg: \(msg)")
//        print("IDf : \(idf)")
          switch idf[1] {
              case "Login":
                  print("hello I'm here")
                  let msg = String(message.string!)
                  let msg_splitLine = msg.split(separator: ",")
                  if msg_splitLine[0] == "True"{
//                        print("Login success")
                    clientID = String(msg_splitLine[1])
                    subTopicMain()
                    let notificationName = Notification.Name("NotifiacationLogin")
                    NotificationCenter.default.post(name: notificationName, object: nil)
                    UserDefaults.LoginInfo.set(value: true, forKey: .token)
                    UserDefaults.LoginInfo.set(value: msg_splitLine[1], forKey: .cardID)
                  }else{
                        print("Login fail")
                  }
              case "GetUserData":
                  let msg = String(message.string!)
                  let notificationNameMQTT = Notification.Name("NotificationMQTT")
                  let name = String(msg.split(separator :"\r")[0])
//                  print("name:\(name)")
                  let nameDict:[String: String] = ["name": name]
                  NotificationCenter.default.post(name: notificationNameMQTT, object: nil, userInfo: nameDict)
                  mqtt.publish("IDF/GetUserIcon/\(clientID!)", withString: String(""))
              case "GetUserIcon":
                let bytes : [UInt8] = message.payload
                let data = NSData(bytes: bytes, length: bytes.count)
                let iconDict:[String: NSData] = ["icon": data]
                let notificationNameMQTT = Notification.Name("NotificationMQTT")
                NotificationCenter.default.post(name: notificationNameMQTT, object: nil, userInfo: iconDict)
              case "Initialize":
                let msg = String(message.string!)
                let initDic:[String: String] = ["init": msg]
                NotificationCenter.default.post(name: notificationNameMQTT, object: nil, userInfo: initDic)
                timing = 2
              case "GetRecord":
                let msg = String(message.string!)
                let notificationName = Notification.Name("UpdateMSG")
                let recordDict:[String: String] = ["record": msg]
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: recordDict)
              case "RecordImgBack":
                  let msg = String(message.topic)
                  let pos: Int? = Int(String(msg.split(separator: "/")[3]))
                  let bytes : [UInt8] = message.payload
                  let data = NSData(bytes: bytes, length: bytes.count)
                  let iconDict:[String: tupleDict] = ["RecordImgBack": tupleDict(num: pos!, data: data)]
                  let notificationNameMQTT = Notification.Name("RecordImgBack")
                  NotificationCenter.default.post(name: notificationNameMQTT, object: nil, userInfo: iconDict)
              case "SendMessage":
                  let msg = String(message.string!)
//                  print("sendMSG: \(msg)")
                  let msg_splitLine = msg.split(separator: "\t")
                  for roomInfo in GlobalInfo.shared().roomlist{
                      if roomInfo.code == String(msg_splitLine[0]){
                          roomInfo.rMsg = String(msg_splitLine[2])
                          roomInfo.rMsgDate = String(msg_splitLine[3])
                          let tableviewController: ChatTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatTableViewController") as! ChatTableViewController
                          tableviewController.updateChatList()
                          tableviewController.viewDidLoad()
                          tableviewController.viewWillAppear(true)
                          tableviewController.viewDidAppear(true)
                          let msgDict:[String: String] = ["SendMessage": msg]
                          NotificationCenter.default.post(name: Notification.Name("UpdateMSG"), object: nil, userInfo: msgDict)
                          break
                      }
                  }
                  break
              default:
                if(idf[1].contains("FriendIcon")){
                    let FID = String(idf[1].split(separator: ":")[1])
                    if(idf[1].contains("Init")){
                        print("FID: \(FID)")
                        let bytes : [UInt8] = message.payload
                        let data = NSData(bytes: bytes, length: bytes.count)
                        let FiconDict:[String: String] = ["ficon": FID]
                        for room in GlobalInfo.shared().roomlist{
                            if FID == room.ID{
                                room.setIcon(img: UIImage(data:data as Data)!)
                                GlobalInfo.shared().friendAvatarMap.updateValue(UIImage(data:data as Data)!, forKey: room.ID)
                                break
                            }
                        }
                        let notificationFIcon = Notification.Name("NotificationFIcon")
                        NotificationCenter.default.post(name: notificationFIcon, object: nil, userInfo: FiconDict)
                    }
                }
          }
//        guard let temp = message.string else { return }
//        let strary:[String] = temp.components(separatedBy: ";")
//        let msgID = strary[0]
//        let memberID = strary[1]
//        let memberName = strary[2]
//        let msg = strary[3]
//        let notificationName = Notification.Name(rawValue: "\(message.topic)")
//        NotificationCenter.default.post(name: notificationName, object: self,
//                                        userInfo: ["topicID": message.topic,"msgID": msgID, "memberID": memberID, "memberName": memberName, "msg": msg])
//
//        if( message.topic != curtopic){ // Unread notification.
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Unread"), object: self,
//                                            userInfo: ["topicID": message.topic,"msgID": msgID, "memberID": memberID, "memberName": memberName, "msg": msg])
//        }
        
        
        //        let name = NSNotification.Name(rawValue: "MQTTMessageNotification" + animal!)
        //        NotificationCenter.default.post(name: name, object: self, userInfo: ["message": message.string!, "topic": message.topic])
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("subscribe topic: \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
//        print("topic: \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("mqttDidping")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
//        print("mqttDidReceivePong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
//                print("\(err.description)")
        print("mqttDidDisconnect")
        if(timing == 2){
            DispatchQueue.main.async {
                print("mqttDidDisconnect")
                self.mqtt.connect()
            }
        }
    }
}

// My func
extension MQTTManager {
    
    func setupMQTT(num: Int){
        timing = num
        mqtt.connect()
        
        /*
        mqtt.didReceiveMessage = { mqtt, message, id in
            //處理接收過來的資料
            let stringValue = "Message received in topic \(message.topic) with payload \(message.string!)"
            let notificationName = Notification.Name(rawValue: "ReceiveMessageNotification")
            NotificationCenter.default.post(name: notificationName, object: self,
                                            userInfo: ["msg":stringValue])
            print("Message received in topic \(message.topic) with payload \(message.string!)")
        }
        */
    }
    func stopMQTT(){
        mqtt.disconnect()
    }
    
    func checkConnectState() -> Bool{
        if (mqtt.connState == CocoaMQTTConnState.connected){
            return true
        }else{
            return false
        }
    }
}

struct tupleDict {
    var num: Int
    var data: NSData
}
