//
//  Task.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/04.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import Foundation
import SwiftyJSON

class Task{
    var ID : Int = 0
    var objectId : String = ""
    var lastUpdate : NSDate = NSDate()
    var title : String
    var memo : String
    var isDone : Bool = false
    var isMark : Bool = false
    var isDelete : Bool = false
    init(title: String , memo: String){
        self.title = title
        self.memo = memo
    }
    
    func compare(t:Task) -> Bool  {
        if title == t.title {
            if memo == t.memo {
                if isDone == t.isDone {
                    if isMark == t.isMark {
                        if isDelete == t.isDelete {
                            if 0 == lastUpdate.timeIntervalSinceDate(t.lastUpdate) {
                                return true
                            }
                        }
                    }                }
            }
        }
        return false
    }
    
    func clone()->Task {
        var task = Task(title: title,memo: memo)
        task.ID  = ID
        task.objectId = objectId
        task.lastUpdate = lastUpdate
        task.isDone = isDone
        task.isMark = isMark
        task.isDelete = isDelete
        return task
    }
    // TaskwoJSONに変換する

    func toJson() -> String {
        var str = "{"
        //https://parse.com/questions/which-json-date-format-is-supported-by-rest-api
        str += "\"lastUpdate\":{\"__type\":\"Date\",\"iso\":\"\(toIso(lastUpdate))\"}"
        str += ","
        str += "\"title\":\"\(title)\""
        str += ","
        str += "\"memo\":\"\(escape(memo))\""
        str += ","
        str += "\"isDone\":\(isDone)"
        str += ","
        str += "\"isMark\":\(isMark)"
        str += ","
        str += "\"isDelete\":\(isDelete)"
        str += "}"
        return str
    }
   
    func fromJson(json:SwiftyJSON.JSON) -> Bool {
        if
            let objectId : String = json["objectId"].string,
            lastUpdateStr : String = json["lastUpdate"]["iso"].string,
            title : String = json["title"].string,
            memo : String = json["memo"].string,
            isDone : Bool = json["isDone"].bool,
            isMark : Bool = json["isMark"].bool,
            isDelete : Bool = json["isDelete"].bool {
                //この時点では、lastUpdateStrがNSDateに変換できるかどうかは、まだ不明
                if let lastUpdate = self.toNSDate(lastUpdateStr) {
                    self.memo = unescape(memo)
                    self.title = title
                    self.objectId = objectId
                    self.lastUpdate = lastUpdate
                    self.isDone = isDone
                    self.isMark = isMark
                    self.isDelete = isDelete
                    return true
                }
        }
        return false
    }
    
    private func toNSDate(str:String) -> NSDate?{
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.dateFromString(str) as NSDate?
    }
    
    //https://parse.com/docs/rest/guide
    //UTC timestamps stored in ISO 8601 format with millisecond precision:YYYY-MM-DDTHH:MM:SS.MMMZ
    private func toIso(dt:NSDate) -> String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.stringFromDate(dt)
    }
    
    //JSONに変換する前に、特殊文字を置き換える
    private func escape(str:String) -> String {
        var s = str
        for (before,after) in ["\n":"¥n","\r":"¥r"] {
            s = s.stringByReplacingOccurrencesOfString(before, withString: after)
        }
        return s
        
    }
    private func unescape(str:String) -> String{
        var s = str
        for (before,after) in ["¥n":"\n","¥r":"\r"] {
            s = s.stringByReplacingOccurrencesOfString(before, withString: after)
        }
        return s
    }
}

