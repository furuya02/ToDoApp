//
//  HttpClient.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/04.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import UIKit

//Alamofireのラッパークラス
//テスト(モック作成)のために定義した

class HttpClient{

    func request2(method:String,url:String,headers:[String:String]?,body:String?) -> Request {
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        req.HTTPMethod = method
        if let h = headers {
            for (f,v) in h {
                req.addValue(v, forHTTPHeaderField:f)
            }
        }
        if let b = body {
            let strData = b.dataUsingEncoding(NSUTF8StringEncoding)
            req.HTTPBody = strData
        }
        return request(req)
    }

    func responseJSON(request:Request,completionHandler: (
        NSURLRequest,
        NSHTTPURLResponse?,
        AnyObject?,
        NSError?) -> Void ) -> Request{
            
            return request.responseJSON(options: nil, completionHandler: completionHandler)
    }

    func responseString(request:Request,completionHandler: (
        NSURLRequest,
        NSHTTPURLResponse?,
        String?,
        NSError?) -> Void ) -> Request{
            return request.responseString(completionHandler: completionHandler)
    }

    
}
