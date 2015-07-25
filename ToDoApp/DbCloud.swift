//
//  DbCloud.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/12.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import Foundation

// テストの際にモックに置き換えることができるようにプロトタイプで定義する
protocol DbCloud{
    func selectAsync(objectId:String?,completionHandler: (_:AsyncResult<[Task]>) -> Void)
    func insertAsync(task: Task,completionHandler: (_:AsyncResult<Task?>)->Void)
    func pushInstall(deviceToken:String)
    func pushSend(objectId:String)

}