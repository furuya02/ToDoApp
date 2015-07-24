//
//  MockDbCloud.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/12.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import Foundation

class MockDbCloud : MockDb,DbCloud{
    
    override init(){
        super.init()
        mode = .Cloud
    }
    
    func selectAsync(completionHandler: (_:AsyncResult<[Task]>) -> Void){
        completionHandler(AsyncResult<[Task]>(ar))
    }
    
    func insertAsync(task: Task,completionHandler: (_:AsyncResult<Task?>)->Void){
        add(task)
    }
    
    func pushInstall(deviceToken:String){
    }

    
}
