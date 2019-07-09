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
