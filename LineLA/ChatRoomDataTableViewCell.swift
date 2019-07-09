//
//  ChatRoomDataTableViewCell.swift
//  LineLA
//
//  Created by uscclab on 2018/12/23.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit

// DateCell
struct DateCellInfo {
    var date: String!
    var mChatMsgCells: [ChatMsgCellInfo]! = [ChatMsgCellInfo]()
    init(date: String) {
        self.date = date
    }
}

class ChatRoomDataTableViewCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    var dateCell: DateCellInfo!
    
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
extension ChatRoomDataTableViewCell {
    func updateUI() {
        print("\(self.dateCell.mChatMsgCells.count)")
        self.dateLabel.text = self.dateCell.date
        self.backgroundColor = UIColor.clear
    }
}
