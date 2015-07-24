//
//  RepositoryTest.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/12.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import XCTest

class RepositoryTest: XCTestCase {
    
    var localDb = MockDbLocal()
    var cloudDb = MockDbCloud()
    
    
    override func setUp() {
        super.setUp()
        localDb.clear() // DB初期化
        cloudDb.clear() // DB初期化
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSetAsync_新規データを２件追加するとDBは２件になる(){
        
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        let expected = 2

        //exercise
        sut.setAsync(Task(title: "",memo: ""),completeHandler: { (a) in })
        localDb.ar[0].objectId = "Obj1" // 本来は、非同期で更新されるローカルのobjectIdを強制的に更新する
        sut.setAsync(Task(title: "",memo: ""),completeHandler: { (a) in })
        localDb.ar[1].objectId = "Obj2" // 本来は、非同期で更新されるローカルのobjectIdを強制的に更新する

        //verify
        //件数は、両方とも2件となる
        XCTAssert(localDb.count() == 2)
        XCTAssert(cloudDb.count() == 2)
        
        //データは、両方とも新しい方と同じになる
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[1].objectId == "Obj2")
        XCTAssert(cloudDb.ar[1].objectId == "Obj2")
        

        //tearDown
    }
    
    func testSetAsync_同一objectIdのデータを２件追加するとDBは１件（更新）になる(){
        
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        var task = Task(title: "",memo: "")

        //exercise
        sut.setAsync(task,completeHandler: { (a) in })
        localDb.ar[0].objectId = "Obj1" // 本来は、非同期で更新されるローカルのobjectIdを強制的に更新する
        
        task.objectId = "Obj1"
        sut.setAsync(task,completeHandler: { (a) in })
        
        var actual = localDb.count()
        
        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        
        //データは、両方とも新しい方と同じになる
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        
        //tearDown
    }


    func testIntegration_ローカルに存在するがクラウドに存在しない_ObjectIdが有効_ローカルデータは削除される(){
        
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        var task = Task(title: "LOCAL",memo: "")
        task.objectId = "Obj1"
        localDb.add(task)
        
        //exercise
        sut.integration()
        
        //verify
        //件数は、両方とも0件となる
        XCTAssert(localDb.count() == 0)
        XCTAssert(cloudDb.count() == 0)
        
        //tearDown
    }
    
    func testIntegration_ローカルに存在するがクラウドに存在しない場合_ObjectIdが空_クラウドにもコピーされる(){
        
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        var task = Task(title: "LOCAL",memo: "")
        localDb.add(task)
        
        //exercise
        sut.integration()
        
        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        
        
        //tearDown
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        
        XCTAssert(localDb.ar[0].title == "LOCAL")
        XCTAssert(cloudDb.ar[0].title == "LOCAL")
    }

    func testIntegration_クラウドに存在するがローカルに存在しない場合_ローカルにもコピーされる(){
        
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        cloudDb.add(Task(title: "CLOUD",memo: ""))
        
        //exercise
        sut.integration()
        
        //verify
        //件数は、両方とも１件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        //データは、両方とも新しい方と同じになる
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")

        XCTAssert(localDb.ar[0].title == "CLOUD")
        XCTAssert(cloudDb.ar[0].title == "CLOUD")
        
        //tearDown
    }
    
    func testIntegration_lastUpdate_クラウド側のデータが古い場合(){
        
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //クラウド側は１０分前のデータである
        var t1 = Task(title: "CLOUD",memo: "")
        t1.lastUpdate = DateTime().addMinutes(-10).nsdate!
        cloudDb.add(t1)
        
        var t2 = Task(title: "LOCAL",memo: "")
        t2.objectId = "Obj1" // クラウドにあるデータと同一のobjectIdを持つ
        localDb.add(t2)
        
        //exercise
        sut.integration()
        
        //verify
        //件数は、両方とも１件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        //データは、両方とも新しい方と同じになる
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "LOCAL")
        XCTAssert(cloudDb.ar[0].title == "LOCAL")
        
        //tearDown
    }

    func testIntegration_lastUpdate_ローカル側のデータが古い場合(){
        
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //ローカル側は１０分前のデータである
        var t1 = Task(title: "CLOUD",memo: "")
        cloudDb.add(t1)
        var t2 = Task(title: "LOCAL",memo: "")
        t2.objectId = "Obj1" // クラウドにあるデータと同一のobjectIdを持つ
        t2.lastUpdate = DateTime().addMinutes(-10).nsdate!
        localDb.add(t2)
        
        //exercise
        sut.integration()
        
        //verify
        //件数は、両方とも１件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        //データは、両方とも新しい方と同じになる
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "CLOUD")
        XCTAssert(cloudDb.ar[0].title == "CLOUD")
        
        //tearDown
    }
    
//    func testSetAsync_整合がとれた状態からローカルのデータを修正した場合(){
//        
//        //setUp
//        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
//
//        var t1 = Task(title: "BEFORE",memo: "")
//        localDb.add(t1)
//        sut.integration() // 整合
//        //この時点で、両DBに１件のデータが存在する
//        
//        //exercise
//        var t2 = Task(title: "AFTER",memo: "")
//        //同一のデータであるということは、objectIdが同じである必要がある
//        t2.objectId = t1.objectId
//        sut.setAsync(t2, completeHandler: { (a) in })
//        
//        //verify
//        //件数は、両方とも１件となる
//        XCTAssert(localDb.count() == 1)
//        XCTAssert(cloudDb.count() == 1)
//        //データは、両方とも新しい方と同じになる
//        XCTAssert(localDb.ar[0].objectId == "Obj1")
//        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
//        XCTAssert(localDb.ar[0].title == "AFTER")
//        XCTAssert(cloudDb.ar[0].title == "AFTER")
//        
//        //tearDown
//    }

    func testSetAsync_整合がとれた状態からクラウドのデータを修正し_再度整合した場合(){
        
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        var t1 = Task(title: "BEFORE",memo: "")
        localDb.add(t1)
        sut.integration() // 整合
        //この時点で、両DBに１件のデータが存在する
    
        //クラウドのデータを修正する
        cloudDb.ar[0].title = "CHANGE"
        cloudDb.ar[0].lastUpdate = DateTime(nsdate: cloudDb.ar[0].lastUpdate).addMinutes(1).nsdate! // 修正時刻を１分進める
        
    
        //exercise
        sut.integration() // 再度、整合処理を行う
    
    
        //verify
        //件数は、両方とも１件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        //データは、両方とも新しい方と同じになる
        XCTAssert(localDb.ar[0].title == "CHANGE")
        XCTAssert(cloudDb.ar[0].title == "CHANGE")
        
        //tearDown
    }


}
