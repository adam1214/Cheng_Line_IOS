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
    var avatar: UIImage!
    var ID: String!
    var name: String!
    var msg: String!
    var img: UIImage?
    var msgTime: Date!
    var type: Int!      //message from others or self, 0 = others, 1 = self
    var data_t: Int!    //message type, 0 = text data, 1 = image data
}

// defined ChatLeftmsgCell
// Member attribute
class ChatLeftMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var msgTimeLabel: UILabel!
    @IBOutlet weak var bubble: UIImageView!
    @IBOutlet weak var viewImg: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var senderLabel: UILabel!
    var isPresent: Bool!
    var chatMsgCell: ChatMsgCellInfo!
    var present: ((_ img: UIImage)->())!
    var imagetemp: UIImage!
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
    func updateUI(_ present:  @escaping (_ img: UIImage)->()) {
        if chatMsgCell.avatar == nil{
            avatar.image = UIImage(named: "friend_default")?.toCircle()
        }else{
            avatar.image = chatMsgCell.avatar.toCircle()
        }
        msgTimeLabel.text = MsgTimeFormat(date: chatMsgCell.msgTime)
        if(chatMsgCell.name == nil)
        {
            senderLabel.text = chatMsgCell.ID
        }
        else
        {
            senderLabel.text = chatMsgCell.name
        }
        msgTextView.text = chatMsgCell.msg
        imagetemp = nil
        isPresent = false
        var isHiddenMsg = false
        let instruction = chatMsgCell.data_t
        switch instruction {
        case 1:
            isHiddenMsg = true
            self.present = present
            instructionisShowPicture()
            break
        case 0: // self.cRInfo.targetName friend, typeA, typeB(instruction, replyModify) and typeC(replyParticipate)
            isHiddenMsg = false
            instructionisDefault()
            break
        default:
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
    
    func instructionisShowPicture() {
        msgTextView.isHidden = true
        bubble.isHidden = true
        viewImg.isHidden = false
        imgView.isHidden = false
        let image = chatMsgCell.img!
        imagetemp = image
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let size = contentView.frame.size
        let maxValue = size.width - 84
        var tempimg: UIImage!
        if imageWidth > imageHeight { tempimg = image.scaleImage(scaleSize: maxValue/imageWidth) }
        else { tempimg = image.scaleImage(scaleSize: maxValue/imageHeight) }
        imgView.image = tempimg
        imgView.layer.cornerRadius = 30
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewClick))
        imgView.addGestureRecognizer(singleTapGesture)
        imgView.isUserInteractionEnabled = true
    }
    
    func instructionisDefault() {
        viewImg.isHidden = true
        imgView.isHidden = true
        msgTextView.isHidden = false
        bubble.isHidden = false
        imgView.image = nil
    }

}
