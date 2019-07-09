//
//  MQTTManager.swift
//  LineLA
//
//  Created by uscclab on 2018/11/13.
//  Copyright © 2018 uscclab. All rights reserved.
//

import Foundation
import CocoaMQTT

struct TopicList{
    private var topics: [String] = [String]()
}

extension TopicList {

    mutating func append(topicName: String) {
        topics.append(topicName)
    }

    mutating func getTopic(index: Int) -> String {
        return topics[index]
    }

    mutating func count() -> Int {
        return topics.count
    }

    mutating func getTopics() -> [String] {
        return topics
    }

    mutating func setTopic(index: Int, topicName: String) {
        topics[index] = topicName
    }

    mutating func contains(topicName: String) -> Bool {
        return topics.contains(topicName)
    }

    mutating func removeAll() {
        topics.removeAll()
    }
}

// Member attribute
class MQTTManager: NSObject{
    let USERNAME = "LineLA"
    let PASSWORD = "LineLA"
    var mqtt: CocoaMQTT!
    var topicList: TopicList!
    var curtopic: String!
    
    private static var mqttManager: MQTTManager = {
        return MQTTManager()
    }()
    
    private override init(){
        super.init()
        self.topicList = TopicList()
        self.curtopic = ""
        
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: "140.116.82.34", port: 1883)
        
        mqtt.username = USERNAME
        mqtt.password = PASSWORD
        
        mqtt.keepAlive = 60
        mqtt.delegate = self
    }

    
    class func shared() -> MQTTManager {
        return mqttManager
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
            if (topicList.count() > 0) {
                for topic in topicList.getTopics() {
                    mqtt.subscribe(topic,qos: CocoaMQTTQOS.qos2)
                }
            }
            //            mqtt.subscribe("chat/room/animals/client/+", qos: CocoaMQTTQOS.qos1)
            //
            //            let chatViewController = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
            //            chatViewController?.mqtt = mqtt
            //            navigationController!.pushViewController(chatViewController!, animated: true)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        print("new state: \(state)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
//        print("message: \(String(describing: message.string?.description)), id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
//        print("id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
//        print("message: \(String(describing: message.string?.description)), id: \(id)")
//        print("topic: \(message.topic)")
        guard let temp = message.string else { return }
        let strary:[String] = temp.components(separatedBy: ";")
        let msgID = strary[0]
        let memberID = strary[1]
        let memberName = strary[2]
        let msg = strary[3]
        let notificationName = Notification.Name(rawValue: "\(message.topic)")
        NotificationCenter.default.post(name: notificationName, object: self,
                                        userInfo: ["topicID": message.topic,"msgID": msgID, "memberID": memberID, "memberName": memberName, "msg": msg])
        
        if( message.topic != curtopic){ // Unread notification.
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Unread"), object: self,
                                            userInfo: ["topicID": message.topic,"msgID": msgID, "memberID": memberID, "memberName": memberName, "msg": msg])
        }
        
        
        //        let name = NSNotification.Name(rawValue: "MQTTMessageNotification" + animal!)
        //        NotificationCenter.default.post(name: name, object: self, userInfo: ["message": message.string!, "topic": message.topic])
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
//        print("topic: \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
//        print("topic: \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("mqttDidping")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("mqttDidReceivePong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
//                print("\(err.description)")
        print("mqttDidDisconnect")
        DispatchQueue.main.async {
            print("mqttDidDisconnect")
            self.mqtt.connect()
        }
    }
}

// My func
extension MQTTManager {
    
    func setupMQTT(){
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
        self.topicList.removeAll()
        mqtt.disconnect()
    }
}
