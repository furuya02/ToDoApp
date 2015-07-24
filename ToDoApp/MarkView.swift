//
//  MarkView.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/20.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import UIKit

class MarkView : HeaderView{
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.summerSky()
        
        // サブビューの検索
        for childView in subviews {
            if let v = childView as? UILabel {
                let label = v
                label.textColor = UIColor.solitude()
            }
        }
        
    }

}