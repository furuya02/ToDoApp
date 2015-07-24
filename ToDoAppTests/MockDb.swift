//
//  MockDb.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/12.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import Foundation

enum MockDbMode{
    case Local
    case Cloud
}

class MockDb {

    var ar:[Task]=[]
    var mode : MockDbMode = .Local
    var counter : Int = 1
    
    func count() -> Int{
        return ar.count
    }
    
    func clear(){
        ar = []
    }
    
    func add(task:Task){
        switch mode {
        case .Local:
            if var i = search(task.ID) {
                ar[i] = task.clone()
            }else{
                task.ID = counter++
                ar.append(task.clone())
            }
        case .Cloud:
            if var i = search(task.objectId) {
                ar[i] = task.clone()
            }else{
                task.objectId = "Obj\(counter++)"
                ar.append(task.clone())
            }
        }
    }
    func del(task:Task){
        switch mode {
        case .Local:
            if var i = search(task.ID) {
                ar.removeAtIndex(i)
            }
        case .Cloud:
            if var i = search(task.objectId) {
                ar.removeAtIndex(i)
            }
        }
    }
    
    private func search(objectId:String) -> Int? {
        for var i = 0 ;i < ar.count ; i++ {
            if ar[i].objectId == objectId {
                return i
            }
        }
        return nil
    }

    private func search(ID:Int) -> Int? {
        for var i = 0 ;i < ar.count ; i++ {
            if ar[i].ID == ID {
                return i
            }
        }
        return nil
    }
}
