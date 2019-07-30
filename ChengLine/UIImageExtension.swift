//
//  UIImageExtension.swift
//  LineLA
//
//  Created by uscclab on 2018/10/22.
//  Copyright © 2018 uscclab. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func toCircle() -> UIImage { // 裁切圖型成圓形
        let shotest = min(self.size.width, self.size.height)
        let outputRect = CGRect(x: 0, y: 0, width: shotest, height: shotest)
        UIGraphicsBeginImageContextWithOptions(outputRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.addEllipse(in: outputRect)
        context.clip()
        self.draw(in: CGRect(x: (shotest-self.size.width)/2,
                             y: (shotest-self.size.height)/2,
                             width: self.size.width,
                             height: self.size.height))
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return maskedImage
    }
    
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale)
        self.draw(in:CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return reSizeImage
    }
    
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
    
    func imageFill(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            if size.height > size.width {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            } else {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            }
        } else {
            if size.height > size.width {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            } else {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            }
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
