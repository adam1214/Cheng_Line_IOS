//
//  ObserverController.swift
//  LineLA
//
//  Created by uscclab on 2018/10/3.
//  Copyright © 2018 uscclab. All rights reserved.
//

import AVFoundation
import UIKit

// ScannerObserver
// Member attribute
class ScannerObserver: NSObject {

    var barcode: String!
    var activity: (() -> ())! // callback func by using closure
    
    init(activity: @escaping () -> ()){
        super.init()
        self.activity = activity
        self.barcode = nil
        let notificationName = Notification.Name(rawValue: "GetBarcodeNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(getBarcode(notification:)), name:notificationName, object: nil)
    }
    
    deinit {
        
        self.barcode = nil
        self.activity = nil
        //記得移除通知監聽
        NotificationCenter.default.removeObserver(self)
        
    }
    
}

// My func
extension ScannerObserver {

    @objc private func getBarcode(notification: Notification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        self.barcode = userInfo["barcode"] as? String
        self.activity()
    }
    
}

// DeviceOrientationObserver
// Member attribute
class DeviceOrientationObserver: NSObject {
    var activity: ((_ orientation: UIDeviceOrientation) -> ())! // callback func by using closure
    
    init(activity: @escaping (_ orientation: UIDeviceOrientation) -> ()){
        super.init()
        self.activity = activity
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            // 生成通知
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange), name:UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    deinit {
        self.activity = nil
        //記得移除通知監聽
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
}

// My func
extension DeviceOrientationObserver {
    
    @objc private func onDeviceOrientationChange(){
        activity(UIDevice.current.orientation)
    }
    
}

// KeyboardObserver
// Member attribute
class KeyboardObserver: NSObject {
    var setKeyboard: ((_ height: CGFloat) -> ())!
    
    init(activity: @escaping (_ height: CGFloat) -> ()) {
        super.init()
        setKeyboard = activity
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDisShow(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    deinit {
        self.setKeyboard = nil
        //記得移除通知監聽
        NotificationCenter.default.removeObserver(self)
    }
}

extension KeyboardObserver: UITextFieldDelegate{
    @objc private func handleKeyboardDisShow(notification: NSNotification) {
        // get Keyboard frame
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let value = userInfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey)
        let keyboardRec = (value as AnyObject).cgRectValue.height
        setKeyboard(keyboardRec)
    }
}

// MessageObserver
// Member attribute
class MessageObserver: NSObject {
    var topicID: String!
    var msgID: String!
    var memberID: String!
    var memberName: String!
    var msg: String!
    var activity: (() -> ())! // callback func by using closure
    
    init(activity: @escaping () -> (),id: String!) {
        super.init()
        
        self.activity = activity
        let notificationName = Notification.Name(rawValue: id)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveMessage(notification:)), name:notificationName, object: nil)
    }
    
    deinit {
        //記得移除通知監聽
        self.topicID = nil
        self.msgID = nil
        self.memberID = nil
        self.memberName = nil
        self.msg = nil
        self.activity = nil
        NotificationCenter.default.removeObserver(self)
    }
    
}

// My func
extension MessageObserver {
    
    @objc private func receiveMessage(notification: Notification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        self.topicID = userInfo["topicID"] as? String
        self.msgID = userInfo["msgID"] as? String
        self.memberID = userInfo["memberID"] as? String
        self.memberName = userInfo["memberName"] as? String
        self.msg = userInfo["msg"] as? String
        
        self.activity()
    }
    
}
