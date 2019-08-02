//
//  ChatTableViewCell.swift
//  LineLA
//
//  Created by uscclab on 2018/11/6.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit

// defined chatCell
// Member attribute
class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var chatName: UILabel!
    @IBOutlet weak var displayMsg: UILabel!
    @IBOutlet weak var displayDate: UILabel!
    
    var roomInfo: RoomInfo!
}

// Override func
extension ChatTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension ChatTableViewCell{
    func updateUI(){
        imgAvatar.image = roomInfo.icon.toCircle()
        chatName.text = roomInfo.roomName
        
        if roomInfo.rMsg == "No History"{
            displayMsg.text = ""
        }else{
            displayMsg.text = roomInfo.rMsg
        }
        
        if roomInfo.rMsgDate == "1970-00-00 00:00"{
            displayDate.text = ""
        }else{
            let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let today_str = dateFormatter.string(from: Date())
            let timeInterval: TimeInterval = -(24*60*60)
            let yesterday = Date().addingTimeInterval(timeInterval)
            let yesterday_str = dateFormatter.string(from: yesterday)
            
            let dateSplit = String(roomInfo.rMsgDate.split(separator: " ")[0])
            let timeSplit = String(roomInfo.rMsgDate.split(separator: " ")[1])

            if(yesterday_str == dateSplit){
                displayDate.text = "昨天"
            }else if(today_str == dateSplit){
                let splitLine = timeSplit.split(separator: ":")
                displayDate.text = String(splitLine[0] + ":" + splitLine[1])
            }else{
                let splitLine = dateSplit.split(separator: "-")
                displayDate.text = String(splitLine[1] + "/" + splitLine[2])
            }
        }
    }
}
