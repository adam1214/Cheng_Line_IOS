//
//  CallViewController.swift
//  LineLA
//
//  Created by uscclab on 2019/3/27.
//  Copyright © 2019 uscclab. All rights reserved.
//

import UIKit

// Member attribute
class CallViewController: UIViewController {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var muteBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var endCallBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    var isCallOut: Bool!
    var isCallOn: Bool!
    var profile: ProfileInfo!
    var shared: GlobalInfo!
    var linphoneManager: LinphoneManager!
    var lastController: UIViewController!
    var iterateTimer: Timer?
}

// Override func
extension CallViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        // Do any additional setup after loading the view.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}

// My func
extension CallViewController {
    func prepare() {
        self.linphoneManager = shared.linphoneManager
        self.imgView.image = self.profile.avatar
        self.nameLabel.text = self.profile.profileName
        self.timeLabel.text = ""
        self.isCallOn = false
        self.videoBtn.isEnabled = false
        lastController = self.linphoneManager.theLinphone.controller
        self.linphoneManager.theLinphone.controller = self
        if isCallOut {
            //            self.timeLabel.text =
            self.timeLabel.text = "撥號中..."
            self.linphoneManager.makeCall(calleeAccount: self.profile.phoneNb)
        } else { // Callin
            self.timeLabel.text = "正在撥電話給你"
        }
        updateUI()
        
        videoBtn.imageView?.image = videoBtn.currentImage?.toCircle()
    }
    
    func updateUI(){
        if isCallOut || isCallOn{
            self.muteBtn.isHidden = false
            self.muteBtn.superview?.isHidden = false
            self.videoBtn.isHidden = false
            self.videoBtn.superview?.isHidden = false
            self.videoBtn.superview?.superview?.isHidden = false
            self.videoBtn.superview?.subviews[1].isHidden = false
            self.speakerBtn.isHidden = false
            self.speakerBtn.superview?.isHidden = false
            self.endCallBtn.isHidden = false
            self.endCallBtn.superview?.isHidden = false
            self.acceptBtn.isHidden = true
            self.acceptBtn.superview?.isHidden = true
            self.rejectBtn.isHidden = true
            self.rejectBtn.superview?.isHidden = true
        } else { // isCallin
            self.muteBtn.isHidden = true
            self.muteBtn.superview?.isHidden = true
            self.videoBtn.isHidden = true
            self.videoBtn.superview?.isHidden = true
            self.videoBtn.superview?.superview?.isHidden = true
            self.videoBtn.superview?.subviews[1].isHidden = true
            self.speakerBtn.isHidden = true
            self.speakerBtn.superview?.isHidden = true
            self.endCallBtn.isHidden = true
            self.endCallBtn.superview?.isHidden = true
            self.acceptBtn.isHidden = false
            self.acceptBtn.superview?.isHidden = false
            self.rejectBtn.isHidden = false
            self.rejectBtn.superview?.isHidden = false
        }
    }
    
    @objc func updateTime(){
        let timeInterval = Double(linphoneManager.getCallDuration())
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        DispatchQueue.main.async {
            self.timeLabel.text = dateFormatter.string(from: date)
        }
    }
    
    func setTimer(){
        self.iterateTimer = Timer.scheduledTimer(
            timeInterval: 0.5, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func exitUI(){
        if self.iterateTimer != nil{
            self.iterateTimer!.invalidate()
            self.iterateTimer = nil
        }
        self.linphoneManager.theLinphone.controller = lastController
        dismiss(animated: false)
    }
}

// IBAction func
extension CallViewController {
    @IBAction func acceptBtnClick(_ sender: Any) {
        linphoneManager.acceptCall()
    }
    
    @IBAction func rejectBtnClick(_ sender: Any) {
        linphoneManager.endCall()
        exitUI()
    }
    
    @IBAction func muteBtnClick(_ sender: Any) {
        if self.muteBtn.backgroundColor != UIColor.white {
            self.muteBtn.backgroundColor = UIColor.white
        } else {
            self.muteBtn.backgroundColor = UIColor.groupTableViewBackground
        }
        linphoneManager.switchMicro()
    }
    
    @IBAction func videoBtnClick(_ sender: Any) {
        
    }
    
    @IBAction func speakerBtnClick(_ sender: Any) {
        if self.speakerBtn.backgroundColor != UIColor.white {
            self.speakerBtn.backgroundColor = UIColor.white
        } else {
            self.speakerBtn.backgroundColor = UIColor.groupTableViewBackground
        }
        linphoneManager.switchSpeaker()
    }
    
    @IBAction func endCallBtnClick(_ sender: Any) {
        linphoneManager.endCall()
        exitUI()
    }
}
