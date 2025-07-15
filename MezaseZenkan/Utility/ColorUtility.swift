//
//  ColorUtility.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/03.
//

import UIKit

struct RGB255 {
    
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat = 1.0
    
    init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.red = CGFloat(red)
        self.green = CGFloat(green)
        self.blue = CGFloat(blue)
        self.alpha = alpha
    }
    
    var uiColor: UIColor {
        return UIColor(red: self.red / 255, green: self.green / 255, blue: self.blue / 255, alpha: self.alpha)
    }
}

