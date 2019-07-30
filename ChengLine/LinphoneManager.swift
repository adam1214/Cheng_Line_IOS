//
//  LinphoneManager.swift
//  LineLA
//
//  Created by uscclab on 2019/3/27.
//  Copyright © 2019 uscclab. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

var answerCall: Bool = false

struct TheLinphone {
    var lc: OpaquePointer?           // LinphoneCore
    var lccbs: OpaquePointer?         // LinphoneCoreCbs
    var call: OpaquePointer?         // LinphoneCall
    var isOverrideSpeaker: Bool?
    var controller: UIViewController?
}

let registrationStateChanged: LinphoneCoreCbsRegistrationStateChangedCb  = {
    (lc: Optional<OpaquePointer>, proxyConfig: Optional<OpaquePointer>, state: _LinphoneRegistrationState, message: Optional<UnsafePointer<Int8>>) in
    switch state{
    case LinphoneRegistrationNone: /**<Initial state for registrations */
        print("Hey!!! LinphoneRegistrationNone")
        
    case LinphoneRegistrationProgress:
        print("Hey!!! LinphoneRegistrationProgress")
        
    case LinphoneRegistrationOk:
        print("Hey!!! LinphoneRegistrationOk")
        
    case LinphoneRegistrationCleared:
        print("Hey!!! LinphoneRegistrationCleared")
        
    case LinphoneRegistrationFailed:
        print("Hey!!! LinphoneRegistrationFailed")
        
    default:
        print("Hey!!! Unkown registration state")
    }
    } as LinphoneCoreRegistrationStateChangedCb

let callStateChanged: LinphoneCoreCallStateChangedCb = {
    (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, callSate: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in
    var linphoneManager = LinphoneManager.shared()
    switch callSate{
    case LinphoneCallStateIncomingReceived: /**<This is a new incoming call */
        print("Hey!!! callStateChanged: LinphoneCallIncomingReceived")
        linphoneManager.theLinphone.isOverrideSpeaker = true
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            //                try AVAudioSession.sharedInstance().setActive(true)
        } catch { print(error) }
        let cl = linphone_call_get_call_log(call)
        let fromAddress = linphone_call_log_get_from_address(cl)
        let username = String(cString: linphone_address_get_username(fromAddress))
        let shared = GlobalInfo.shared()
        let mTVC = shared.mTVCDataManager
        var profile: ProfileInfo?
        print("callon username:" + username)
        for typeInfo in mTVC.FTVCData {
            for profileInfo in typeInfo.ProfileInfos {
                print("callon "+profileInfo.phoneNb!)
                if profileInfo.phoneNb == username {
                    print("callon ok!")
                    profile = profileInfo
                    break
                }
            }
            if profile != nil { break }
        }
        if profile == nil {
            print("callon not ok!")
            linphone_call_terminate(call)
            break
        }
        linphoneManager.theLinphone.call = linphone_call_ref(call!)
        let lc = linphone_call_get_core(call)
        if let controller = linphoneManager.theLinphone.controller!.storyboard?.instantiateViewController(withIdentifier: "CallViewController") as? CallViewController {
            print("present")
            controller.shared = GlobalInfo.shared()
            controller.profile = profile
            controller.isCallOut = false
            linphoneManager.theLinphone.controller!.present(controller, animated: true, completion: nil)
        }

        if answerCall{
            ms_usleep(3 * 1000 * 1000) // Wait 3 seconds to pickup
            linphone_call_accept_update(call, lc)
        }
        
    case LinphoneCallStateStreamsRunning: /**<The media streams are established and running*/
        print("Hey!!! callStateChanged: LinphoneCallStreamsRunning")
        if let controller = linphoneManager.theLinphone.controller as? CallViewController {
            controller.isCallOn = true
            controller.updateUI()
            controller.setTimer()
        }
        linphoneManager.theLinphone.isOverrideSpeaker = false
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print(error) }
        
    case LinphoneCallStateEnd: /**<The call encountered an error*/
        print("Hey!!! callStateChanged: LinphoneCallStateEnd")
        if let call = linphoneManager.theLinphone.call {
            linphone_call_unref(linphoneManager.theLinphone.call)
        }
        if let controller = linphoneManager.theLinphone.controller as? CallViewController {
            controller.exitUI()
        }
        
    case LinphoneCallStateError: /**<The call encountered an error*/
        print("Hey!!! callStateChanged: LinphoneCallError")
        if let call = linphoneManager.theLinphone.call {
            linphone_call_unref(linphoneManager.theLinphone.call)
        }
        if let controller = linphoneManager.theLinphone.controller as? CallViewController {
            controller.exitUI()
        }
        
    default:
        print("Hey!!! Default call state")
    }
}

// Member attribute
class LinphoneManager: NSObject {
    static var iterateTimer: Timer?
    
    private var account: String!    // Put your account name here
    private var password: String!   // Put your account password here
    let domain = "140.116.82.34" // Put your domain here
    var theLinphone: TheLinphone!
    private static var linphoneManager: LinphoneManager = {
        return LinphoneManager()
    }()
    
    private override init() {
        super.init()
        self.account = ""
        self.password = ""
        theLinphone = TheLinphone()
        self.theLinphone.lc = nil
        self.theLinphone.lccbs = nil
        self.theLinphone.call = nil
        self.theLinphone.isOverrideSpeaker = false
        self.theLinphone.controller = nil
    }
    
    class func shared() -> LinphoneManager {
        return linphoneManager
    }
}

// My func
extension LinphoneManager {
    
    fileprivate func bundleFile(_ file: NSString) -> NSString{
        return Bundle.main.path(forResource: file.deletingPathExtension, ofType: file.pathExtension)! as NSString
    }
    
    fileprivate func documentFile(_ file: NSString) -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsPath: NSString = paths[0] as NSString
        return documentsPath.appendingPathComponent(file as String) as NSString
    }
    
    private func initLinphoneManager() {
        // Enable debug log to stdout
        linphone_logging_service_set_log_level(linphone_logging_service_get(), LinphoneLogLevelDebug)
        // Load config
        let configFilename = documentFile("linphonerc")
        let factoryConfigFilename = bundleFile("linphonerc-factory")
        
        let configFilenamePtr: UnsafePointer<Int8> = configFilename.cString(using: String.Encoding.utf8.rawValue)!
        let factoryConfigFilenamePtr: UnsafePointer<Int8> = factoryConfigFilename.cString(using: String.Encoding.utf8.rawValue)!
        let lpConfig = linphone_config_new_with_factory(configFilenamePtr, factoryConfigFilenamePtr)
        
        // init theLinphone
        let factory = linphone_factory_get()
        self.theLinphone.lc = linphone_factory_create_core_with_config_3(factory, lpConfig, nil)
        self.theLinphone.lccbs = linphone_factory_create_core_cbs(factory)
        self.theLinphone.call = nil
        self.theLinphone.isOverrideSpeaker = false
        // Set Callback
        linphone_core_cbs_set_registration_state_changed(self.theLinphone.lccbs, registrationStateChanged)
        linphone_core_cbs_set_call_state_changed(self.theLinphone.lccbs, callStateChanged)
        linphone_core_add_callbacks(self.theLinphone.lc, self.theLinphone.lccbs)
        linphone_core_set_max_calls(self.theLinphone.lc, 1)
        
        // Set ring asset
        let url = Bundle.main.url(forResource: "ring", withExtension: "bundle")
        let bundle = Bundle(url: url!)
        let ringbackPath = bundle!.path(forResource: "ringback", ofType: "wav")
        linphone_core_set_ringback(self.theLinphone.lc, ringbackPath)
        
        let localRing = bundle!.path(forResource: "localRing", ofType: "wav")
        linphone_core_set_ring(self.theLinphone.lc, localRing)
    }
    
    private func idle(){
        guard setIdentify() != nil else {
            print("no identity")
            return
        }
        linphone_core_start(self.theLinphone.lc)
        setTimer()
    }
    
    func makeCall(calleeAccount: String!){
        self.theLinphone.call = linphone_call_ref(linphone_core_invite(self.theLinphone.lc, calleeAccount))
        linphone_call_enable_echo_cancellation(self.theLinphone.call, 1)
        linphone_call_enable_echo_limiter(self.theLinphone.call, 1)
    }
    
    func acceptCall() {
        // Received
        if linphone_call_get_state(self.theLinphone.call) == LinphoneCallStateIncomingReceived {
            linphone_call_accept(self.theLinphone.call)
        }
    }
    
    func endCall() {
        self.theLinphone.isOverrideSpeaker = true
        switchSpeaker()
        linphone_call_terminate(self.theLinphone.call)
    }
    
    func switchSpeaker(){
        if !self.theLinphone.isOverrideSpeaker! {
            self.theLinphone.isOverrideSpeaker = true
            //            linphone_call_set_speaker_muted(theLinphone.call, 0)
            do{
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: .defaultToSpeaker)
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch { print(error) }
            //            linphone_call_set_speaker_volume_gain(theLinphone.call, val)
        } else {
            self.theLinphone.isOverrideSpeaker = false
            do{
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch { print(error) }
        }
    }
    
    func switchMicro() {
        if linphone_core_in_call(self.theLinphone.lc) == 1 {
            let flag = linphone_core_mic_enabled(self.theLinphone.lc)
            if flag == 1 { linphone_core_enable_mic(self.theLinphone.lc, 0) }
            else { linphone_core_enable_mic(self.theLinphone.lc, 1) }
        }
    }
    
    func getCallDuration() -> Int {
        return Int(linphone_core_get_current_call_duration(self.theLinphone.lc))
    }
    
    func setIdentify() -> OpaquePointer? {
        let identity = "sip:" + account + "@" + domain
        print("okkkk----: " + identity)
        
        /*create proxy config*/
        let proxy_cfg = linphone_core_create_proxy_config(self.theLinphone.lc)
        
        /*parse identity*/
        let from = linphone_address_new(identity)
        
        if (from == nil){
            print("\(identity) not a valid sip uri, must be like sip:toto@sip.linphone.org")
            return nil
        }
        let info=linphone_auth_info_new(linphone_address_get_username(from), nil, password, nil, nil, nil) /*create authentication structure from identity*/
        linphone_core_add_auth_info(self.theLinphone.lc, info) /*add authentication info to LinphoneCore*/
        
        // configure proxy entries
        linphone_proxy_config_set_identity_address(proxy_cfg, from)
        /*set identity with user name and domain*/
        let server_addr = String(cString: linphone_address_get_domain(from)) /*extract domain address from identity*/
        
        linphone_proxy_config_set_server_addr(proxy_cfg, server_addr) /* we assume domain = proxy server address*/
        linphone_proxy_config_enable_register(proxy_cfg, 1) /* activate registration for this proxy config*/
        linphone_address_unref(from)
        /*release resource*/
        linphone_core_add_proxy_config(self.theLinphone.lc, proxy_cfg) /*add proxy config to linphone core*/
        linphone_core_set_default_proxy_config(self.theLinphone.lc, proxy_cfg) /*set to default proxy*/
        return proxy_cfg!
    }
    
    func login() {
        let share = GlobalInfo.shared()
        self.account = share.accountInfo.memberID
        self.password = share.accountInfo.memberID
        self.theLinphone.lc = nil
        self.theLinphone.lccbs = nil
        self.theLinphone.call = nil
        self.theLinphone.isOverrideSpeaker = false
        self.theLinphone.controller = nil
        self.initLinphoneManager()
        self.idle()
    }
    
    func logout() {
        self.account = ""
        self.password = ""
        LinphoneManager.iterateTimer?.invalidate()
        LinphoneManager.iterateTimer = nil
        linphone_core_stop(theLinphone.lc)
        linphone_core_clear_proxy_config(theLinphone.lc)
        linphone_core_clear_all_auth_info(theLinphone.lc)
        linphone_core_clear_call_logs(theLinphone.lc)
        linphone_core_cbs_set_registration_state_changed(self.theLinphone.lccbs, nil)
        linphone_core_cbs_set_call_state_changed(self.theLinphone.lccbs, nil)
        linphone_core_remove_callbacks(theLinphone.lc, theLinphone.lccbs)
        linphone_factory_clean()
        self.theLinphone.lc = nil
        self.theLinphone.lccbs = nil
        self.theLinphone.call = nil
        self.theLinphone.isOverrideSpeaker = false
        self.theLinphone.controller = nil
    }
    
    @objc func iterate(){
        if let lc = self.theLinphone.lc{
            linphone_core_iterate(lc) /* first iterate initiates registration */
        }
    }
    
    fileprivate func setTimer(){
        LinphoneManager.iterateTimer = Timer.scheduledTimer(
            timeInterval: 0.02, target: self, selector: #selector(iterate), userInfo: nil, repeats: true)
    }
}
