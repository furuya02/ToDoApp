//
//  TaskTest.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/10.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import XCTest

class TaskTest: XCTestCase {

    //MARK: - clone()

    func testCloneでデータの複製ができるか(){

        //setUp
        let sut = CreateBaseTask()

        //exercise
        var actual = sut.clone()

        //verify
        XCTAssert(actual.ID == sut.ID)
        XCTAssert(actual.objectId == sut.objectId)
        XCTAssert(actual.title == sut.title)
        XCTAssert(actual.memo == sut.memo)
        XCTAssert(actual.isDone == sut.isDone)
        XCTAssert(actual.isDelete == sut.isDelete)
        var interval = Int(actual.lastUpdate.timeIntervalSinceDate(sut.lastUpdate))
        XCTAssert(interval == 0)
        
        //tearDown
    }

    //MARK: - compare()

    func testCompare_データに相違がない場合trueが返る() {
        
        //setUp
        let task = CreateBaseTask()
        
        let sut = CreateBaseTask()
        let expected = true
        
        //exercise
        var actual = sut.compare(task)
        
        //verify
        XCTAssert(actual == expected)
        
        //tearDown
    }
    
    func testCompare_データに相違があるがlastUpdateが同一の場合falseが返る() {
        
        //setUp
        let task = CreateBaseTask()
        task.title = "XXXX"
        
        
        let sut = CreateBaseTask()
        let expected = false
        
        //exercise
        var actual = sut.compare(task)
        
        //verify
        XCTAssert(actual == expected)
        
        //tearDown
    }

    func testCompare_データに相違があり_対象のlastUpdateが新しい場合falseが返る() {
        
        //setUp
        let task = CreateBaseTask()
        task.title = "XXXX"
        task.lastUpdate = NSDate(timeInterval: 60, sinceDate: task.lastUpdate) // 60秒後に設定
        
        
        let sut = CreateBaseTask()
        let expected = false
        
        //exercise
        var actual = sut.compare(task)
        
        //verify
        XCTAssert(actual == expected)
        
        //tearDown
    }
    
    func testCompare_データに相違があり_対象のlastUpdateが古い場合falseが返る() {
        
        //setUp
        let task = CreateBaseTask()
        task.title = "XXXX"
        task.lastUpdate = NSDate(timeInterval: -60, sinceDate: task.lastUpdate) // 60秒前に設定
        
        
        let sut = CreateBaseTask()
        let expected = false
        
        //exercise
        var actual = sut.compare(task)
        
        //verify
        XCTAssert(actual == expected)
        
        //tearDown
    }

    func testToJson_CreateBaseTaskのままで出力してみる() {
        
        //setUp
        let sut = CreateBaseTask()
        let expected = "{\"lastUpdate\":{\"__type\":\"Date\",\"iso\":\"2015-01-01T00:00:00.000Z\"},\"title\":\"title\",\"memo\":\"memo\",\"isDone\":false,\"isDelete\":false}"
        //exercise
        var actual = sut.toJson()
        
        //verify
        XCTAssert(actual == expected)
        
        //tearDown
    }
    
    
    
    // MARK: - Support Function

    // 基準Taskの生成
    private func CreateBaseTask() -> Task{
        return CreateTask(0,objectId:"",lastUpdate:"2015-01-01 00:00:00",title: "title",memo: "memo",isDone:false,isDelete:false)
    }
    
    // Taskの生成
    private func CreateTask(ID:Int,objectId:String,lastUpdate:String,title:String,memo:String,isDone:Bool,isDelete:Bool) -> Task{
        
        let task = Task(title: title,memo:memo)
        task.ID = ID
        task.objectId = objectId
        
        // "2014-12-01 10:00:00"
        var date_formatter: NSDateFormatter = NSDateFormatter()
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        task.lastUpdate = date_formatter.dateFromString(lastUpdate)!
        
        task.isDone = isDone
        task.isDelete = isDelete
        return task
    }
    
    

}
