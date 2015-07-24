//
//  UIToggleButton.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/04.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import UIKit

@IBDesignable
class UIToggleButton: UIButton {
    
    //UIButtonType.Customにする必要があります
    
    @IBInspectable var onImage : UIImage?
    @IBInspectable var offImage : UIImage?
    
    @IBInspectable var sw:Bool = false {
        didSet{
            self.setImage(sw ? onImage : offImage, forState: .Normal)
        }
    }
}


