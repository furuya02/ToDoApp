//
//  DbLocal.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/12.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import Foundation

// テストの際にモックに置き換えることができるようにプロトタイプで定義する
protocol DbLocal{
    func select() -> [Task]
    func insert(task: Task) -> Bool
    func search(objectId:String) -> Task?
    func delete(task: Task) -> Bool
}
