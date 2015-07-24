//
//  UIColorExtension.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/18.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import UIKit

extension UIColor{
    class func fromRgba(r:Int,g:Int,b:Int,a:CGFloat) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    class func solitude() -> UIColor { // #ECEEF1 白
        return UIColor.fromRgba(236, g: 238, b: 241, a: 1.0)
    }
    class func summerSky() -> UIColor { // #40AAEF 青
        return UIColor.fromRgba(64, g: 170, b: 239, a: 1.0)
    }
    class func lightCorol() -> UIColor { // #F27398 ピンク
        return UIColor.fromRgba(242, g: 115, b: 152, a: 1.0)
    }
    class func silverTree() -> UIColor { // #58BE89 緑
        return UIColor.fromRgba(88, g: 190, b: 137, a: 1.0)
    }
    class func blackBlock() -> UIColor { // #363947 黒
        return UIColor.fromRgba(54, g: 57, b: 71, a: 1.0)
    }
    class func veryLightGrey() -> UIColor { // #CCCCCC グレー
        return UIColor.fromRgba(204, g: 204, b: 204, a: 1.0)
    }
    class func mySin() -> UIColor { // #FBA848 オレンジ
        return UIColor.fromRgba(251, g: 168, b: 72, a: 1.0)
    }
    class func denim() -> UIColor { // #0E7AC4 濃青
        return UIColor.fromRgba(14, g: 122, b: 196, a: 1.0)
    }

    
}
