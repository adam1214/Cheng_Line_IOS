//
//  GlobalInfo.swift
//  LineLA
//
//  Created by uscclab on 2018/12/17.
//  Copyright © 2018 uscclab. All rights reserved.
//

import Foundation
import UIKit

class RoomInfo {
    var code: String
    var ID :String
    var roomName: String
    var type: String
    var rMsg: String
    var rMsgDate: String
    var icon: UIImage
    
    init(code: String,ID:String,roomName: String, type: String, rMsg: String, rMsgDate: String){
        self.code = code
        self.ID = ID
        self.roomName = roomName
        self.type = type
        self.rMsg = rMsg
        self.rMsgDate = rMsgDate
        self.icon = UIImage(named: "default_group")!
    }
    
    func setIcon(img: UIImage){
        self.icon = img
    }
}

struct AccountInfo {
    var memberName: String? {
        get { return UserDefaults.AccountInfo.string(forKey: .memberName) }
        set { UserDefaults.AccountInfo.set(value: newValue, forKey: .memberName) }
    }
    var memberID: String? {
        get { return UserDefaults.AccountInfo.string(forKey: .memberID) }
        set { UserDefaults.AccountInfo.set(value: newValue, forKey: .memberID) }
    }
    var memberAvatar: UIImage? {
        get {
            if let name = UserDefaults.AccountInfo.string(forKey: .memberAvatarPath) {
                let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let imageURL = documentDirectory.appendingPathComponent(name)
                return UIImage(contentsOfFile: imageURL.path)
            }
            return nil
        }
        set {
            if let image = newValue{
                let name = "memberAvatar.png"
                let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let imageURL = documentDirectory.appendingPathComponent("memberAvatar.png")
                if let imageData = image.jpegData(compressionQuality: 1.0) { try! imageData.write(to: imageURL) }
                UserDefaults.AccountInfo.set(value: name, forKey: .memberAvatarPath)
            }
        }
    }
    var unReadCount: Int? {
        get { return UserDefaults.AccountInfo.integer(forKey: .unReadCount) }
        set { UserDefaults.AccountInfo.set(value: newValue, forKey: .unReadCount) }
    }
    init(memberName: String?, memberID: String?, memberAvatar: UIImage?, unReadCount: Int?) {
        if let memberName = memberName { self.memberName = memberName }
        if let memberID = memberID { self.memberID = memberID }
        if let memberAvatar = memberAvatar { self.memberAvatar = memberAvatar }
        if let unReadCount = unReadCount { self.unReadCount = unReadCount }
    }
}

struct LoginInfo {
    var token: Bool {
        get { return UserDefaults.LoginInfo.bool(forKey: .token) }
        set { UserDefaults.LoginInfo.set(value: newValue, forKey: .token) }
    }
    var cardID: String? {
        get { return UserDefaults.LoginInfo.string(forKey: .cardID) }
        set { UserDefaults.LoginInfo.set(value: newValue, forKey: .cardID) }
    }
    
    init(token: Bool, cardID: String?) {
        self.token = token
        if let cardID = cardID { self.cardID = cardID }
    }
}

//struct SettingInfo {
//    var chatRoomBackgroud: UIImage? {
//        get{
//            if let data = UserDefaults.SettingInfo.data(forKey: .chatRoomBackgroudData){
//                return UIImage(data:data)
//            } else {
//                return UIImage()
//            }
//        }
//        set{
//            if let img = newValue{
//                UserDefaults.SettingInfo.set(value: UIImagePNGRepresentation(img), forKey: .chatRoomBackgroudData)
//            }
//        }
//    }
//
//    init(chatRoomBackgroud: UIImage?) {
//        self.chatRoomBackgroud = chatRoomBackgroud
//    }
//}

class TVCDataManager: NSObject {
    var FTVCData:[TypeInfo]
    var CRTVCData:[DateCellInfo]
    private static var mTVCDataManager: TVCDataManager = {
        return TVCDataManager()
    }()
    
    private override init() {
        self.FTVCData = [TypeInfo]()
        self.CRTVCData = [DateCellInfo]()
    }
    
    class func shared() -> TVCDataManager {
        return mTVCDataManager
    }
}

class DateUtil: NSObject {
    private static var mDateUtil: DateUtil = {
        return DateUtil()
    }()
    
    private override init() {
        super.init()
    }
    
    class func shared() -> DateUtil {
        return mDateUtil
    }
}

extension DateUtil {
    func getDateFromString(withFormat strFormat: String, strDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = strFormat
        dateFormatter.locale = Locale.ReferenceType.system
        dateFormatter.timeZone = TimeZone.ReferenceType.system
        return dateFormatter.date(from: strDate)!
    }
    
    func getLocalDate(date: Date) -> String {
        var format = ""
        if Locale.current.identifier == "zh_TW" {
            format = "MMMd日 EEE"
        } else {
            format = "EEE, MMM d"
        }
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func getLocalDate() -> String {
        var format = ""
        if Locale.current.identifier == "zh_TW" {
            format = "MMMd日 EEE"
        } else {
            format = "EEE, MMM d"
        }
        let date: Date = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func getMsgTime() -> Date {
        let date: Date = Date()
        return date
    }
}


//
class GlobalInfo: NSObject {
    var accountInfo: AccountInfo
    var loginInfo: LoginInfo
    //    var setting: SettingInfo
    var mTVCDataManager: TVCDataManager
    var mqttManager: MQTTManager
    var databaseManager: DatabaseManager
    var linphoneManager: LinphoneManager
    var dateUtil: DateUtil
    var unReadcout: Int
    var roomlist: [RoomInfo]
    var aliasMap: [String: String]
    
    private static var sharedGlobal: GlobalInfo = {
        let accountInfo = setupAccountInfo()
        let loginInfo = setupLoginInfo()
//        let settingInfo = setupSettingInfo()
        return GlobalInfo(accountInfo,loginInfo)
    }()
    
    private init(_ accountInfo: AccountInfo, _ loginInfo: LoginInfo/*, _ setting: SettingInfo*/) {
        self.accountInfo = accountInfo
        self.loginInfo = loginInfo
        self.roomlist = [RoomInfo]()
        self.aliasMap = [String: String]()
//        self.setting = setting
        mqttManager = MQTTManager.shared()
        databaseManager = DatabaseManager.shared()
        mTVCDataManager = TVCDataManager.shared()
        linphoneManager = LinphoneManager.shared()
        dateUtil = DateUtil.shared()
        unReadcout = 0
    }
    
    class func shared() -> GlobalInfo {
        return sharedGlobal
    }
}


// My func
extension GlobalInfo{
    private static func setupAccountInfo() -> AccountInfo {
        let memberName = UserDefaults.AccountInfo.string(forKey: .memberName)
        let memberID = UserDefaults.AccountInfo.string(forKey: .memberID)
        var memberAvatar: UIImage?
        if let url = UserDefaults.AccountInfo.url(forKey: .memberAvatarPath) {
            memberAvatar = UIImage(contentsOfFile: url.path)
        }
        let unReadCount = UserDefaults.AccountInfo.integer(forKey: .unReadCount)
        return AccountInfo(memberName: memberName, memberID: memberID, memberAvatar: memberAvatar, unReadCount: unReadCount)
    }
    
    private static func setupLoginInfo() -> LoginInfo {
        let token = UserDefaults.LoginInfo.bool(forKey: .token)
        let cardID = UserDefaults.LoginInfo.string(forKey: .cardID)
        return LoginInfo(token: token, cardID: cardID)
    }
    
    //    private static func setupSettingInfo() -> SettingInfo {
    //
    //        var chatRoomBackgroud: UIImage?
    //        if let data = UserDefaults.SettingInfo.data(forKey: .chatRoomBackgroudData) {
    //            chatRoomBackgroud = UIImage(data: data)
    //        }
    //        let aSetting = SettingInfo(chatRoomBackgroud: chatRoomBackgroud)
    //        return AccountInfo(memberName: memberName, memberID: memberID, memberAvatar: memberAvatar)
    //    }
    
    
    
    private func clearGlobalInfo() {
        UserDefaults.AccountInfo.removeObject(forKey: .memberName)
        UserDefaults.AccountInfo.removeObject(forKey: .memberID)
        UserDefaults.AccountInfo.removeObject(forKey: .memberAvatarPath)
        UserDefaults.LoginInfo.set(value: false, forKey: .token)
        UserDefaults.LoginInfo.removeObject(forKey: .cardID)
        
    }
    
    func clearAppInfo() {
        self.clearGlobalInfo()
//        self.mqttManager.stopMQTT()
        self.roomlist.removeAll()
        self.aliasMap.removeAll()
    }
}

// My static func
extension GlobalInfo{
    // Download data from server by HTTP protocol. (URLSession)
    static func getProfile(memberID: String?,activity: @escaping (_ responseData: Data)->()) {  // get profile.
//        if let memberID = memberID {
//            let scheme = "http://140.116.82.34/communicate/GetUserProfile.php?memberID=\(memberID)"
//            let url:URL! = URL(string: scheme)
//            // make the request
//            let task = URLSession.shared.dataTask(with: url) {
//                (data, response, error) in
//                // check for any errors
//                guard error == nil else {
//                    print("error calling GET on /todos/1")
//                    print(error!)
//                    return
//                }
//                // make sure we got data
//                guard let responseData = data else {
//                    print("Error: did not receive data")
//                    return
//                }
//                activity(responseData)
//            }
//            task.resume()
//        }
    }
    
    // Download data from server by HTTP protocol. (URLSession)
    static func getRelation(memberID: String?,activity: @escaping (_ responseData: Data)->()) {  // get Relation Data.
//        if let memberID = memberID{
//            let scheme = "http://140.116.82.34/communicate/GetRelationData.php?memberID=\(memberID)"
//            let url:URL! = URL(string: scheme)
//            // make the request
//            let task = URLSession.shared.dataTask(with: url) {
//                (data, response, error) in
//                // check for any errors
//                guard error == nil else {
//                    print("error calling GET on /todos/1")
//                    print(error!)
//                    return
//                }
//                // make sure we got data
//                guard let responseData = data else {
//                    print("Error: did not receive data")
//                    return
//                }
//                activity(responseData)
//            }
//            task.resume()
//        }
    }
}
