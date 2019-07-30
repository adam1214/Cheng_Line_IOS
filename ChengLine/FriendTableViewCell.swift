//
//  FriendTableViewCell.swift
//  LineLA
//
//  Created by uscclab on 2018/11/6.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit
// ProfileInfo
struct ProfileInfo {
    var profileName: String!
    var section: Int!
    var chatRoomID: String!
    var avatar: UIImage!
    var phoneNb: String?
}

// defined FriendCell
// Member attribute
class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var profileName: UILabel!	
    var phoneNb: String?
    var profile: ProfileInfo!
    var present: ((_ profile:ProfileInfo) -> ())!
}

// Override func
extension FriendTableViewCell {
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
extension FriendTableViewCell {
    func updateUI(_ active: @escaping (_ profile:ProfileInfo)->()) {
        imgAvatar.image = profile.avatar.toCircle()
        profileName.text = profile.profileName
        if let section = profile.section {
            if section == 3 {
                self.phoneNb = profile.phoneNb
                self.present = active
            }
        }
    }
}

// IBAction func
extension FriendTableViewCell {
    @IBAction func callmember(){
        print("call" + self.phoneNb!)
        self.present(self.profile)
    }
}
