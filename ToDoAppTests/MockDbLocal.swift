//
//  MockDbLocal.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/12.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import Foundation

class MockDbLocal : MockDb,DbLocal {
    
    override init(){
        super.init()
        mode = .Local
    }
    
    func search(objectId:String) -> Task? {
        var ar = select()
        for a in ar {
            if(a.objectId == objectId){
                return a
            }
        }
        return nil
    }
    
    func select() -> [Task]{
        return ar
    }
    
    func insert(task: Task) -> Bool{
        add(task)
        return true
    }
    
    func delete(task: Task) -> Bool{
        del(task)
        return true
    }
    
}