//
//  TypeTableViewCell.swift
//  LineLA
//
//  Created by uscclab on 2018/11/6.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit
// TypeInfo.
struct TypeInfo {
    var typeLabelText: String!
    var ProfileInfos: [ProfileInfo]! = [ProfileInfo]()
    var open: Bool = false
    init(typeLabelText: String!){
        self.typeLabelText = typeLabelText
    }
}

// defined typeCell.
// Member attribute
class TypeTableViewCell: UITableViewCell {
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    
    var open: Bool = false
//    var sectionData: [FriendTableViewCell]! = [FriendTableViewCell]()
    var type: TypeInfo!
}

// Override func
extension TypeTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        typeLabel.text = "Group: Type X"
//        open = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

// My func
extension TypeTableViewCell {
    func updateUI() {
        open = type.open
        typeLabel.text = type.typeLabelText
    }
}
