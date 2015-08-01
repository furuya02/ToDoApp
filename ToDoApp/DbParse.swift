import UIKit

//[SecretKey.swift]
// Paers.com
//struct ParseSecret{
//    static let appId = "pNJxxxxxxxxxxxxxxxxxxxxxxxxGlR" //Application ID
//    static let appKey = "KBixxxxxxxxxxxxxxxxxxxxxxxOqO" //REST API Key
//    static let appMaster = "w0hxxxxxxxxxxxxxxxxxxxxxxls0" //Master Key
//}
//SecretKey構造体は、SecretKey.swiftに定義されていますが、Githubには配置されていません

class DbParse : DbCloud{

    //private let httpClient:HttpClient
    private let tableName = "task"
    private let apiUrl = "https://api.parse.com/1/"
    private var pushId:String = "" // push通知のobjectId(削除用)
    
    var params : [String:String] = [
        "X-Parse-Application-Id" : ParseSecret.appId ,
        "X-Parse-REST-API-Key" : ParseSecret.appKey ,
        "Content-Type" : "application/json"]
    
    //init(httpClient: HttpClient){
      //  self.httpClient = httpClient
    //}
    
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
        
        //let request = httpClient.request2("POST",url: url,headers: params,body: str)
      
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        req.HTTPMethod = "POST"
        for (f,v) in params {
            req.addValue(v, forHTTPHeaderField:f)
        }
        req.HTTPBody = str.dataUsingEncoding(NSUTF8StringEncoding)

        request(req).responseJSON(completionHandler: {
            (_, _, data, error) in
            if let error = error {
                NSLog("ERROR " + error.localizedDescription)
            }else{
                if data != nil {
                    let json:JSON = JSON(data!)
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
        
        //let request = httpClient.request2("DELETE",url: url,headers: params,body: nil)
        
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        req.HTTPMethod = "DELETE"
        for (f,v) in params {
            req.addValue(v, forHTTPHeaderField:f)
        }
        
        request(req).responseJSON(completionHandler: {
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

        
//        let request = httpClient.request2("POST",url: url,headers: params,body: str)
  
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        req.HTTPMethod = "POST"
        for (f,v) in params {
            req.addValue(v, forHTTPHeaderField:f)
        }
        req.HTTPBody = str.dataUsingEncoding(NSUTF8StringEncoding)
        
        request(req).responseJSON(completionHandler: {
            (_, _, data, error) in
            if let error = error {
                NSLog("ERROR " + error.localizedDescription)
            }else{
                if data != nil {
                    let json:JSON = JSON(data!)
                    println(json)
                }
            }
        })
        
    }
    
    // 一覧
    func selectAsync(completionHandler: (_:AsyncResult<[Task]>) -> Void) {
        selectAsync(nil,completionHandler: completionHandler)
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
        
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        req.HTTPMethod = "GET"
        for (f,v) in params {
           req.addValue(v, forHTTPHeaderField:f)
        }
//        if let b = body {
//            let strData = b.dataUsingEncoding(NSUTF8StringEncoding)
//            req.HTTPBody = strData
//        }
        request(req).responseJSON(options: nil, completionHandler: {
            (_, _ , data, error) in
            if let error = error {
                NSLog(error.localizedDescription + "  code=\(error.code)")
                completionHandler(AsyncResult(error))
            }else{
                var ar:[Task] = []
                
                if data != nil {
                    let json:JSON = JSON(data!)
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
//        let request = httpClient.request2(method,url: url,headers: params,body: tmpTask.toJson())
        
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        req.HTTPMethod = method
        for (f,v) in params {
            req.addValue(v, forHTTPHeaderField:f)
        }
        req.HTTPBody = tmpTask.toJson().dataUsingEncoding(NSUTF8StringEncoding)

        request(req).responseJSON(options: nil,completionHandler: {
            (_, _, data, error) in
            if let error = error {
                completionHandler(AsyncResult(error))
            }else{
                if data != nil {
                    let json:JSON = JSON(data!)
                    
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
    
    
    //削除
    func deleteAsync(task: Task,completionHandler: (_:AsyncResult<Task?>)->Void){
        var url = apiUrl + "classes/" + tableName + "/" + task.objectId
        var method = "DELETE"
        
        //let request = httpClient.request2(method,url: url,headers: params,body: nil)
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        req.HTTPMethod = "DELETE"
        for (f,v) in params {
            req.addValue(v, forHTTPHeaderField:f)
        }
        
        request(req).responseJSON(options: nil,completionHandler: {
            (_, _, data, error) in
            if let error = error {
                completionHandler(AsyncResult(error))
            }else{
                if data != nil {
                    let json:JSON = JSON(data!)
                }
                completionHandler(AsyncResult(nil))
            }
        })
    }

    
    private func toNSDate(str:String) -> NSDate?{
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.dateFromString(str) as NSDate?
    }
}
