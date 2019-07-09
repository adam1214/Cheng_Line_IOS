//
//  DatabaseManager.swift
//  LineLA
//
//  Created by uscclab on 2018/10/4.
//  Copyright © 2018 uscclab. All rights reserved.
//


// unused...
import Foundation
import SQLite
import UIKit

/*struct DatabaseManager
{   // todo: class single mode. reference mqttmanager.swift
    public var db: Connection!
    public var user: UserList!
}*/

struct Profile
{
    private var aj: Int64!
}

/*
 ChatRoomListTable
   UUID  | memberName |  section   | chatRoomID |  phoneNumber |  Avatar  | msg
 --------|------------|------------|------------|--------------|----------|--
 (Stirng)|  (Stirng)  |  (Stirng)  |  (Stirng)  |   (Stirng)   | (String) |
 
 
 GeneralChatRoomTable (Friend, TypeA)
   UUID  | memberID | memberName |  Avatar  |    msg   | time
 --------|----------|------------|----------|----------|--
 (Stirng)| (Stirng) |  (Stirng)  | (Stirng) | (Stirng) |
 
 TypeBChatRoomTable (TypeB)...
   UUID  | memberID | memberName |  Avatar  |    msg   |
 --------|----------|------------|----------|----------|--
 (Stirng)| (Stirng) |  (Stirng)  | (Stirng) | (Stirng) |
 
 TypeCChatRoomTable (TypeC)...
   UUID  | memberID | memberName |  Avatar  |    msg   |
 --------|----------|------------|----------|----------|--
 (Stirng)| (Stirng) |  (Stirng)  | (Stirng) | (Stirng) |
*/
struct ChatRoomTable
{
    private var db: Connection!
    
    //chatRoomTable
    private var table: Table                                        // 表名
    private let uuid = Expression<String>("uuid")                   // Key
    private let memberId = Expression<String>("memberId")           // ID
    private let memberName = Expression<String>("memberName")       // Name
    private let memberAvatar = Expression<String>("memberAvatar")   // Avatar (path)
    private let msg = Expression<String>("msg")                     // message
    private let msgTime = Expression<Date>("msgTime")
    //private let isLogin = Expression<Bool>("isLogin")               //列表５ 登入狀態 ---
    //
    
    init(_db: Connection)
    {
        self.db = _db
        self.table = Table("")
        connectionDB()
    }
    
    //創建資料庫文件
    mutating func connectionDB(filePath: String = "/Documents")
    {
        
        let sqlFilePath = NSHomeDirectory() + filePath + "/LAdb.sqlite3"
        do { db = try Connection(sqlFilePath) }
        catch { print(error) }
    }
    
    
    mutating func setTableName(_ tableName:String){
        self.table = Table(tableName)   // tableName = topicID
        // TODO: check tableName existence
    }
    
    func createTable(){
        do
        {
            try db.run(table.create
            {
                t in
                t.column(uuid, primaryKey: true)
                t.column(memberId)
                t.column(memberName)
                t.column(memberAvatar)
                t.column(msg)
                t.column(msgTime)
            })
        } catch { print(error) }
    }
    
    //插入資料
    func insertData( _uuid: String,_memberId: String, _memberName: String, _memberAvatar: String, _msg: String, _msgTime: Date)
    {
        do {
            let insert = table.insert(uuid <- _uuid, memberId <- _memberId, memberName <- _memberName, memberAvatar <- _memberAvatar, msg <- _msg, msgTime <- _msgTime)
            try db.run(insert)
        } catch { print(error) }
    }
    
    //讀取資料
    func readData() -> [(uuid: String, memberId: String, memberName: String, memberAvatar: String, msg: String, msgTime: Date)]
    {
        var rowData = (uuid: "",memberId: "", memberName: "", memberAvatar: "", msg:"", msgTime:Date())
        var rowDataArr = [rowData]
        for data in try! db.prepare(table) {
            rowData.uuid = data[uuid]
            rowData.memberId = data[memberId]
            rowData.memberName = data[memberName]
            rowData.memberAvatar = data[memberAvatar]
            rowData.msg = data[msg]
            rowData.msgTime = data[msgTime]
//            print("\(rowData.memberId). \(rowData.memberName)  \(rowData.msg)")
            //userData.isLogin = user[isLogin]
            rowDataArr.append(rowData)
        }
        return rowDataArr
    }
    
    //更新資料  // TODO:
    func upDate(_uuid: String, old_memberName: String, new_memberName: String)
    {
        let currRowData = table.filter(uuid == _uuid)
        do { try db.run(currRowData.update(memberName <- memberName.replace(old_memberName, with: new_memberName))) }
        catch { print(error) }
    }
    
    //刪除資料
    func delData(_uuid: String)
    {
        let currUser = table.filter(uuid == _uuid)
        do { try db.run(currUser.delete()) }
        catch { print(error) }
    }
}

class DatabaseManager: NSObject
{
    var chatRoomTable:ChatRoomTable
    var db: Connection!
    private static var databaseManager: DatabaseManager =
    {
        return DatabaseManager()
    }()
    
    private override init()
    {
        print("init Databasemanager")
        let filePath = "/Documents"
        let sqlFilePath = NSHomeDirectory() + filePath + "/LAdb.sqlite3"
        do { db = try Connection(sqlFilePath) }
        catch { print(error) }
        self.chatRoomTable = ChatRoomTable( _db:db)
        super.init()
    }
    
    deinit
    {
        print("deinit Datanasemanager")
    }
    
    func loadDatas()
    {
        print("loadDatas...")
    }
    class func shared() -> DatabaseManager
    {
        return databaseManager
    }
}
