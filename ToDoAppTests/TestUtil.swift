//
//  TestUtil.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/08/01.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import UIKit

//class TestUtil{
//    // 基準Taskの生成
//    static func CreateBaseTask() -> Task{
//        return CreateTask(0,objectId:"",lastUpdate:"2015-01-01 00:00:00",title: "title",memo: "memo",isDone:false,isDelete:false)
//    }
//    
//    // Taskの生成
//    static func CreateTask(ID:Int,objectId:String,lastUpdate:String,title:String,memo:String,isDone:Bool,isDelete:Bool) -> Task{
//        
//        let task = Task(title: title,memo:memo)
//        task.ID = ID
//        task.objectId = objectId
//        
//        // "2014-12-01 10:00:00"
//        var date_formatter: NSDateFormatter = NSDateFormatter()
//        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
//        task.lastUpdate = date_formatter.dateFromString(lastUpdate)!
//        
//        task.isDone = isDone
//        task.isDelete = isDelete
//        return task
//    }
//    
//}