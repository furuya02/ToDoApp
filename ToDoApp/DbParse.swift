//
//  DbParse.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/04.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import Foundation
import SwiftyJSON

//[SecretKey.swift]
// Paers.com
//    struct ParseSecret{
//        static let appId = "XXXXXXXXXXXXXX6a4Y" //Application ID
//        static let appKey = "XXXXXXXXXXXXXg7Zm" //REST API Key
//    }
//SecretKey構造体は、SecretKey.swiftに定義されていますが、Githubには配置されていません

//TODO　ProtocolでDbSqliteとポリフォリズムを構築する
class DbParse : DbCloud{

    private let httpClient:HttpClient
    private let tableName = "task"
    private let apiUrl = "https://api.parse.com/1/"
    private var pushId:String = "" // push通知のobjectId(削除用)
    
    var params : [String:String] = [
        "X-Parse-Application-Id" : ParseSecret.appId ,
        "X-Parse-REST-API-Key" : ParseSecret.appKey ,
        "Content-Type" : "application/json"]
    
    init(httpClient: HttpClient){
        self.httpClient = httpClient
    }
    
    //Push Notifycation の登録
    func installPush(deviceToken:String){
        let url = apiUrl + "installations/"

        var str = "{"
        str += "\"deviceType\":\"ios\""
        str += ","
        str += "\"deviceToken\":\"\(deviceToken)\""
        str += ","
        str += "\"channels\":[\"todo\"]"
        str += "}"
        
        let request = httpClient.request("POST",url: url,headers: params,body: str)
        
        httpClient.responseJSON(request,completionHandler: {
            (_, _, data, error) in
            if let error = error {
                NSLog("ERROR " + error.localizedDescription)
            }else{
                if data != nil {
                    let json:JSON = SwiftyJSON.JSON(data!)
                    println(json)
                    if let objectId = json["objectId"].string {
                        self.pushId = objectId
                    }

                }
            }
        })

    }
    //Push Notifycation の登録削除
    func uninstallPush(){
        if pushId == "" {
            return
        }
        var params : [String:String] = [
            "X-Parse-Application-Id" : ParseSecret.appId ,
            "X-Parse-Master-Key" : ParseSecret.appMaster ]
        
        let url = apiUrl + "installations/" + pushId
        
        let request = httpClient.request("DELETE",url: url,headers: params,body: nil)
        
        httpClient.responseJSON(request,completionHandler: {
            (_, _, data, error) in
            if let error = error {
                NSLog("ERROR " + error.localizedDescription)
            }else{
                self.pushId = ""
            }
        })
        
    }

    //Push Notifycation の送信
    func sendPush(objectId:String){
        let url = apiUrl + "push"
        
        var str = "{"
        str += "\"channels\":[\"todo\"]"
        str += ","
        str += "\"data\":{"
        str += "\"alert\":\"\(objectId)\""
        str += "}"
        str += "}"

        
        let request = httpClient.request("POST",url: url,headers: params,body: str)
        
        httpClient.responseJSON(request,completionHandler: {
            (_, _, data, error) in
            if let error = error {
                NSLog("ERROR " + error.localizedDescription)
            }else{
                if data != nil {
                    let json:JSON = SwiftyJSON.JSON(data!)
                    println(json)
                }
            }
        })
        
    }
    
    // 一覧
    func selectAsync(completionHandler: (_:AsyncResult<[Task]>) -> Void) {
        
        selectAsync(nil,completionHandler: completionHandler)
        
//        let url = apiUrl + "classes/" + tableName
//        let request = httpClient.request("GET",url: url,headers: params,body: nil)
//        
//        httpClient.responseJSON(request,completionHandler: {
//            (_, _ , data, error) in
//            
//            var ar:[Task] = []
//            
//            if error == nil {
//                if data != nil {
//                    let json:JSON = SwiftyJSON.JSON(data!)
//                    let results = json["results"]
//                    
//                    //すべてのカラムのnilがない場合のみ有効なデータとする
//                    //DBから取り出す時点でunwrapperを完了している、TaskにはOptionl型は存在しない
//                    for (key,j) in json["results"]{
//                        var t = Task(title: "",memo: "")
//                        if t.fromJson(j) {
//                            ar.append(t)
//                        }
//                    }
//                }
//            }
//            completionHandler(AsyncResult(ar))
//        })
    }

    // 一覧
    func selectAsync(objectId:String?,completionHandler: (_:AsyncResult<[Task]>) -> Void) {

        var url = apiUrl + "classes/" + tableName

        if let oid = objectId {
            let str = "where={\"objectId\":\"\(oid)\"}"
            if let encodedStr:String = str.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
                url += "?" + encodedStr
            }
        }
        
        let request = httpClient.request("GET",url: url,headers: params,body: nil)
        httpClient.responseJSON(request,completionHandler: {
            (_, _ , data, error) in
            if let error = error {
                NSLog(error.localizedDescription + "  code=\(error.code)")
                completionHandler(AsyncResult(error))
            }else{
                var ar:[Task] = []
                
                if data != nil {
                    let json:JSON = SwiftyJSON.JSON(data!)
                    let results = json["results"]
                    
                    for (key,j) in json["results"]{
                        var t = Task(title: "",memo: "")
                        if t.fromJson(j) {
                            ar.append(t)
                        }
                    }
                }
                completionHandler(AsyncResult(ar))
            }
        })
    }

    //追加（task.objectId != "" の場合は、更新となる）
    func insertAsync(task: Task,completionHandler: (_:AsyncResult<Task?>)->Void){
        //INSERTの場合
        var url = apiUrl + "classes/" + tableName
        var method = "POST"
        
        //UPDATEの場合
        if task.objectId != "" {
            url += "/\(task.objectId)"//https://api.parse.com/1/classes/tableName/objectId
            method = "PUT"
        }
        // Parse上では、DateTimeが+0900で扱われるので、変換してUPする
        var tmpTask = task.clone()
        tmpTask.lastUpdate = DateTime(nsdate: tmpTask.lastUpdate).addHour(-9).nsdate!
        let request = httpClient.request(method,url: url,headers: params,body: tmpTask.toJson())
        
        httpClient.responseJSON(request,completionHandler: {
            (_, _, data, error) in
            if let error = error {
                completionHandler(AsyncResult(error))
            }else{
                if data != nil {
                    let json:JSON = SwiftyJSON.JSON(data!)
                    
                    //論理エラーが発生している(objectIdが存在しない場合など)
                    if let errorStr = json["error"].string {
                        var code=0
                        if let codeNo = json["code"].int {
                            code = codeNo
                        }
                        var error = NSError(domain: errorStr, code: code, userInfo: nil)
                        completionHandler(AsyncResult(error))
                        return
                    }
                    //INSERT成功
                    if let objectId = json["objectId"].string {
                        task.objectId = objectId
                        completionHandler(AsyncResult(task))
                        return
                    }
                    
                    //UPDATEの場合は、こちら
                    completionHandler(AsyncResult(nil))
                }
            }
        })
    }
    
    private func toNSDate(str:String) -> NSDate?{
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.dateFromString(str) as NSDate?
    }
}
