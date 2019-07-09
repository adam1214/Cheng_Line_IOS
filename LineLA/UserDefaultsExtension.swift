//
//  UserDefaultsExtension.swift
//  LineLA
//
//  Created by uscclab on 2018/12/16.
//  Copyright © 2018 uscclab. All rights reserved.
//

import Foundation
import UIKit

//
extension UserDefaults {
    struct AccountInfo: UserDefaultsSettable {
        internal enum defaultKeys: String {
            case memberName
            case memberID
            case memberAvatarPath
            case unReadCount
        }
    }
    
    struct LoginInfo: UserDefaultsSettable {
        internal enum defaultKeys: String {
            case token
            case cardID
        }
    }
    
    struct SettingInfo: UserDefaultsSettable { // unused
        internal enum defaultKeys: String {
            case chatRoomBackgroudData
        }
    }
}

//
protocol UserDefaultsSettable {
    associatedtype defaultKeys: RawRepresentable
}

extension UserDefaultsSettable where defaultKeys.RawValue==String {
    
    static func set<T>(value: T, forKey key: defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    
    static func string(forKey key: defaultKeys) -> String? {
        let aKey = key.rawValue
        return UserDefaults.standard.string(forKey: aKey)
    }
    
    static func stringArray(forKey key: defaultKeys) -> [String]? {
        let aKey = key.rawValue
        return UserDefaults.standard.stringArray(forKey: aKey)
    }
    
    static func integer(forKey key: defaultKeys) -> Int {
        let aKey = key.rawValue
        return UserDefaults.standard.integer(forKey: aKey)
    }
    
    static func bool(forKey key: defaultKeys) -> Bool {
        let aKey = key.rawValue
        return UserDefaults.standard.bool(forKey: aKey)
    }
    
    static func url(forKey key: defaultKeys) -> URL? {
        let aKey = key.rawValue
        return UserDefaults.standard.url(forKey: aKey)
    }
    
    static func removeObject(forKey key: defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.removeObject(forKey: aKey)
    }
}
