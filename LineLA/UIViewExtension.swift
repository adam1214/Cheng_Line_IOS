//
//  UIViewExtension.swift
//  LineLA
//
//  Created by uscclab on 2018/12/24.
//  Copyright © 2018 uscclab. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
