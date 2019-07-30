//
//  ChatLeftMessageTableViewCell.swift
//  LineLA
//
//  Created by uscclab on 2018/11/20.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit

// chatmsgCell
struct ChatMsgCellInfo {
    var msgID: String!
    var avatar: UIImage!
    var ID: String!
    var name: String!
    var msg: String!
    var msgTime: Date!
}

// defined ChatLeftmsgCell
// Member attribute
class ChatLeftMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var msgTimeLabel: UILabel!
    @IBOutlet weak var bubble: UIImageView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var disagreeButton: UIButton!
    @IBOutlet weak var paddingView: UIView!
    @IBOutlet weak var viewImg: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    var isPresent: Bool!
    var chatMsgCell: ChatMsgCellInfo!
    var present: ((_ img: UIImage)->())!
    var replyOK: ((_ _uuid: String, _ old_memberName: String) -> ())!
    var replyModify: ((_ _uuid: String, _ old_memberName: String) -> ())!
    var replyParticipate: ((_ date: String, _ _uuid: String, _ old_memberName: String) -> ())!
    var imagetemp: UIImage!
    var DBtnWA: NSLayoutConstraint!
}

// Override func
extension ChatLeftMessageTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: self.bounds.size.width)
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

// My func
extension ChatLeftMessageTableViewCell {
    func updateUI(present: @escaping (_ img: UIImage)->(), replyOK: @escaping (_ _uuid: String, _ old_memberName: String) -> (), replyModify: @escaping (_ _uuid: String, _ old_memberName: String) -> (), replyParticipate: @escaping (_ date: String, _ _uuid: String, _ old_memberName: String) -> ()) {
        avatar.image = chatMsgCell.avatar
        msgTimeLabel.text = MsgTimeFormat(date: chatMsgCell.msgTime)
        msgTextView.text = ""
        imagetemp = nil
        isPresent = false
        var isHiddenMsg = false
        let arr = chatMsgCell.name.components(separatedBy: " ")
        var instruction = arr[0]
        if arr.count != 1 && arr[1] == "showPicture" { instruction = arr[1] }
        switch instruction {
        case "annouArrange": // typeB show button msg
            instructionisAnnouArrange()
            self.replyOK = replyOK
            self.replyModify = replyModify
            break
        case "replyOK":
            instructionisReplyOK()
            self.replyModify = replyModify
            break
        case "annouTypeC": //typeC show QRcode image
            instructionisAnnouTypeC()
            self.replyParticipate = replyParticipate
            break
        case "showPicture":
            isHiddenMsg = true
            self.present = present
            instructionisShowPicture()
            break
        case "TypeCGenerateBarcode":
            isHiddenMsg = true
            self.present = present
            instructionisTypeCGenerateBarcode()
            break
        default: // self.cRInfo.targetName friend, typeA, typeB(instruction, replyModify) and typeC(replyParticipate)
            isHiddenMsg = false
            instructionisDefault()
            
            break
        }
        if !isHiddenMsg { msgTextView.text = chatMsgCell.msg }
        bubble.image = setBubble()
        self.backgroundColor = UIColor.clear
    }
    
    func MsgTimeFormat(date:Date) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        return dateFormatter.string(from: date)
    }
    
    func getRepublicOfLocalDate(date:Date) -> String {
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
    
    func setBubble() -> UIImage! {
        return UIImage(named: "bubble_in")!.imageFill(targetSize: CGSize(width: 40, height: 35)).resizableImage(withCapInsets: UIEdgeInsets.init(top: 20, left: 10, bottom: 20, right: 10), resizingMode: UIImage.ResizingMode.stretch)
    }
    
    func getImage() -> UIImage{
        if imgView.image != nil { return imgView.image! }
        return UIImage()
    }
    
    @objc func imageViewClick(){
        if imgView.image != nil { self.present(imagetemp!) }
    }
    
    func generateQRCode(from string: String, imageView: UIImageView) -> UIImage? {
        let data = string.data(using: String.Encoding.utf8)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            // L: 7%, M: 15%, Q: 25%, H: 30%
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            if let qrImage = filter.outputImage {
                let scaleX = imageView.frame.size.width / qrImage.extent.size.width
                let scaleY = imageView.frame.size.height / qrImage.extent.size.height
                let transform = CGAffineTransform(scaleX: CGFloat(scaleX), y: CGFloat(scaleY))
                let output = qrImage.transformed(by: transform)
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    func instructionisAnnouArrange() {
        msgTextView.isHidden = false
        bubble.isHidden = false
        buttonView.isHidden = false
        joinButton.isHidden = true
        agreeButton.isHidden = false
        disagreeButton.isHidden = false
        paddingView.isHidden = false
        imgView.isHidden = true
        imgView.image = nil
        agreeButton.setTitle(NSLocalizedString("OK",comment: ""), for: .normal)
        disagreeButton.setTitle(NSLocalizedString("Modify",comment: ""), for: .normal)
        
//        DBtnWA = disagreeButton.widthAnchor.constraint(equalTo: agreeButton.widthAnchor, constant: 0)
//        DBtnWA.isActive = true
    }
    
    func instructionisReplyOK() {
//        if DBtnWA != nil { DBtnWA.isActive = false }
        msgTextView.isHidden = false
        bubble.isHidden = false
        buttonView.isHidden = false
        joinButton.isHidden = true
        agreeButton.isHidden = true
        disagreeButton.isHidden = false
        paddingView.isHidden = true
        imgView.isHidden = true
        imgView.image = nil
        agreeButton.setTitle("", for: .normal)
        disagreeButton.setTitle(NSLocalizedString("Modify",comment: ""), for: .normal)
//        DBtnWA = disagreeButton.widthAnchor.constraint(equalTo: msgTextView.widthAnchor, constant: 0)
//        DBtnWA.isActive = true
        //            self.replyOK = replyOK
    }
    
    func instructionisAnnouTypeC() {
        msgTextView.isHidden = false
        bubble.isHidden = false
        msgTextView.isHidden = false
        bubble.isHidden = false
        buttonView.isHidden = false
        agreeButton.isHidden = true
        disagreeButton.isHidden = true
        paddingView.isHidden = true
        joinButton.isHidden = false
        imgView.isHidden = true
        imgView.image = nil
        joinButton.setTitle(NSLocalizedString("Join",comment: ""), for: .normal)
    }
    
    func instructionisShowPicture() {
        buttonView.isHidden = true
        agreeButton.isHidden = true
        disagreeButton.isHidden = true
        paddingView.isHidden = true
        joinButton.isHidden = true
        msgTextView.isHidden = true
        bubble.isHidden = true
        viewImg.isHidden = false
        imgView.isHidden = false
        let imgData = Data(base64Encoded: chatMsgCell.msg, options: .ignoreUnknownCharacters)
        let image = UIImage(data: imgData!)
        imagetemp = image
        let imageWidth = image?.size.width
        let imageHeight = image?.size.height
        let size = contentView.frame.size
        let maxValue = size.width - 84
        var tempimg: UIImage!
        if imageWidth! > imageHeight! { tempimg = image!.scaleImage(scaleSize: maxValue/imageWidth!) }
        else { tempimg = image!.scaleImage(scaleSize: maxValue/imageHeight!) }
        imgView.image = tempimg
        imgView.layer.cornerRadius = 30
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewClick))
        imgView.addGestureRecognizer(singleTapGesture)
        imgView.isUserInteractionEnabled = true
    }
    
    func instructionisTypeCGenerateBarcode() {
        buttonView.isHidden = true
        agreeButton.isHidden = true
        disagreeButton.isHidden = true
        paddingView.isHidden = true
        joinButton.isHidden = true
        msgTextView.isHidden = true
        bubble.isHidden = true
        viewImg.isHidden = false
        imgView.isHidden = false
        imgView.frame.size.height = 200.0
        imgView.frame.size.width = 200.0
        imagetemp = generateQRCode(from: chatMsgCell.msg, imageView: imgView)
        imgView.image = imagetemp //tempimg
        imgView.layer.cornerRadius = 30
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewClick))
        imgView.addGestureRecognizer(singleTapGesture)
        imgView.isUserInteractionEnabled = true
    }
    
    func instructionisDefault() {
        buttonView.isHidden = true
        agreeButton.isHidden = true
        disagreeButton.isHidden = true
        paddingView.isHidden = true
        joinButton.isHidden = true
        viewImg.isHidden = true
        imgView.isHidden = true
        msgTextView.isHidden = false
        bubble.isHidden = false
        imgView.image = nil
        agreeButton.setTitle("", for: .normal)
        disagreeButton.setTitle("", for: .normal)
        joinButton.setTitle("", for: .normal)
        if DBtnWA != nil { DBtnWA.isActive = false }
        DBtnWA = disagreeButton.widthAnchor.constraint(equalTo: agreeButton.widthAnchor, constant: 0)
        DBtnWA.isActive = true
    }
}

// IBAction func
extension ChatLeftMessageTableViewCell {
    @IBAction func clickAgreeButton(_ sender: Any) {
        print("clickAgreeButton")
        instructionisReplyOK()
        self.replyOK(self.chatMsgCell.msgID, self.chatMsgCell.name)
        self.chatMsgCell.name = "replyOK 0"
    }
    
    @IBAction func clickDisagreeButton(_ sender: Any) {
        print("clickDisagreeButton")
        instructionisDefault()
        self.replyModify(self.chatMsgCell.msgID, self.chatMsgCell.name)
        self.chatMsgCell.name = "replyModify 0"
    }
    
    @IBAction func chickJOinButton(_ sender: Any) {
        print("chickJOinButton")
        let arr1 = msgTextView.text.components(separatedBy: "\n")
        let arr2 = arr1[3].components(separatedBy: "星")
        let date = arr2[0]
        instructionisDefault()
        self.replyParticipate(date,self.chatMsgCell.msgID, self.chatMsgCell.name)
        self.chatMsgCell.name = "replyParticipate \(date)"
        
    }
}
