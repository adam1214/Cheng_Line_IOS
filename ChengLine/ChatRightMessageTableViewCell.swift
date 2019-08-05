//
//  ChatRightMessageTableViewCell.swift
//  LineLA
//
//  Created by uscclab on 2018/11/20.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit

// Member attribute
class ChatRightMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var msgTimeLabel: UILabel!
    @IBOutlet weak var bubble: UIImageView!
    @IBOutlet weak var viewImg: UIView!
    @IBOutlet weak var imgView: UIImageView!
    var chatMsgCell: ChatMsgCellInfo!
    var present: ((_ img: UIImage)->())!
    var imagetemp: UIImage!
}

// Override func
extension ChatRightMessageTableViewCell {
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
extension ChatRightMessageTableViewCell {
    func updateUI(_ activity:  @escaping (_ img: UIImage)->()) {
        msgTimeLabel.text = MsgTimeFormat(date: chatMsgCell.msgTime)
        msgTextView.text = ""
        var isHiddenMsg = false
        imagetemp = nil
        let instruction = chatMsgCell.data_t
        switch instruction {
            case 1:
//                isHiddenMsg = true
//                msgTextView.isHidden = true
//                bubble.isHidden = true
//                viewImg.isHidden = false
//                imgView.isHidden = false
////                let imgData = Data(base64Encoded: chatMsgCell.msg, options: .ignoreUnknownCharacters)
//                let image = UIImage()
//                imagetemp = image
//                let imageWidth = image.size.width
//                let imageHeight = image.size.height
//                let size = contentView.frame.size
//                let maxValue = size.width - 84
//                var tempimg: UIImage!
//                if imageWidth > imageHeight { tempimg = image.scaleImage(scaleSize: maxValue/imageWidth) }
//                else { tempimg = image.scaleImage(scaleSize: maxValue/imageHeight) }
//                imgView.image = tempimg
//                imgView.layer.cornerRadius = 30
//                self.present = activity
//                let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewClick))
//                imgView.addGestureRecognizer(singleTapGesture)
//                imgView.isUserInteractionEnabled = true
                break
            case 0: // self.cRInfo.targetName friend, typeA and typeB(instruction)
                isHiddenMsg = false
                viewImg.isHidden = true
                imgView.isHidden = true
                msgTextView.isHidden = false
                bubble.isHidden = false
                imgView.image = nil
                imagetemp = nil
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
        return UIImage(named: "bubble_out")!.imageFill(targetSize: CGSize(width: 40, height: 35)).resizableImage(withCapInsets: UIEdgeInsets.init(top: 20, left: 10, bottom: 20, right: 10), resizingMode: UIImage.ResizingMode.stretch)
    }
    
    @objc func imageViewClick(){
        if imgView.image != nil { self.present(imagetemp!) }
    }
}
