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
    
    //MARK: - set()
    func testSet_新規データを1件setすると両DBは共に1件となる(){
        
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //exercise
        sut.set(Task(title: "test1",memo: ""))

        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        //1件目
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "test1")
        XCTAssert(cloudDb.ar[0].title == "test1")
        
        //tearDown
    }
    
    func testSet_新規データを2件setすると両DBは共に2件となる(){
        
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //exercise
        sut.set(Task(title: "test1",memo: ""))
        sut.set(Task(title: "test2",memo: ""))
        
        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 2)
        XCTAssert(cloudDb.count() == 2)
        
        //1件目
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "test1")
        XCTAssert(cloudDb.ar[0].title == "test1")
        //2件目
        XCTAssert(localDb.ar[1].objectId == "Obj2")
        XCTAssert(cloudDb.ar[1].objectId == "Obj2")
        XCTAssert(localDb.ar[1].title == "test2")
        XCTAssert(cloudDb.ar[1].title == "test2")
        
        //tearDown
    }
    
    
    

    func testSet_既存のobjectIdのデータをsetすると上書きになる(){
        
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)

        //テストDBの初期化(Obj1のデータが１件存在する)
        var t = Task(title: "",memo: "")
        t.objectId = "Obj1"
        cloudDb.add(t)
        localDb.add(t)
        
        
        //exercise
        
        var task = Task(title: "test1",memo: "")
        task.objectId = "Obj1"
        sut.set(task)
        var actual = localDb.count()
        
        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        
        //1件目が上書きとなる
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "test1")
        XCTAssert(cloudDb.ar[0].title == "test1")
        
        //tearDown
    }
    
    func testSet_objectIdが空のデータをsetすると追加になる(){
        
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //テストDBの初期化(Obj1のデータが１件存在する)
        var t = Task(title: "",memo: "")
        t.objectId = "Obj1"
        cloudDb.add(t)
        localDb.add(t)
        
        
        //exercise
        var task = Task(title: "test",memo: "")
        sut.set(task)
        var actual = localDb.count()
        
        //verify
        //件数は、両方とも2件となる
        XCTAssert(localDb.count() == 2)
        XCTAssert(cloudDb.count() == 2)
        //1件目は変化なし(既存データ)
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "")
        XCTAssert(cloudDb.ar[0].title == "")
        //Obj2として２件目に追加されている
        XCTAssert(localDb.ar[1].objectId == "Obj2")
        XCTAssert(cloudDb.ar[1].objectId == "Obj2")
        XCTAssert(localDb.ar[1].title == "test")
        XCTAssert(cloudDb.ar[1].title == "test")
        
        //tearDown
    }

    func testSet_クラウド切断時_新規データを1件setするとobjectIdが空の1件となる(){
        
        //setUp
        cloudDb.connect = false // クラウド切断
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //exercise
        sut.set(Task(title: "test1",memo: ""))
        
        //verify
        //件数は、ローカルのみ1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 0)
        //1件目
        XCTAssert(localDb.ar[0].objectId == "") // objectIdが取得できないため空のままになる
        XCTAssert(localDb.ar[0].title == "test1")
        
        //tearDown
    }
    
    func testSet_クラウド切断時_新規データを2件setするとobjectIdが空の2件となる(){
        
        //setUp
        cloudDb.connect = false // クラウド切断
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //exercise
        sut.set(Task(title: "test1",memo: ""))
        sut.set(Task(title: "test2",memo: ""))
        
        //verify
        //件数は、ローカルのみ2件となる
        XCTAssert(localDb.count() == 2)
        XCTAssert(cloudDb.count() == 0)
        
        //1件目
        XCTAssert(localDb.ar[0].objectId == "")
        XCTAssert(localDb.ar[0].title == "test1")
        //2件目
        XCTAssert(localDb.ar[1].objectId == "")
        XCTAssert(localDb.ar[1].title == "test2")
        
        //tearDown
    }

    //MARK: - integration()

    func testIntegration_クラウドに存在しないObjectIdは削除される(){
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //テストDBの初期化(Obj1のデータがローカルのみに１件存在する)
        var t = Task(title: "",memo: "")
        t.objectId = "Obj1"
        localDb.add(t)

        //exercise
        sut.integration()
        
        //verify
        //件数は、両方とも0件となる
        XCTAssert(localDb.count() == 0)
        XCTAssert(cloudDb.count() == 0)
        
        //tearDown
    }

    func testIntegration_objectIdが空のデータはクラウド側にもコピーされる(){
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //テストDBの初期化(objectIdが空のデータがローカルのみに１件存在する)
        var t = Task(title: "test1",memo: "")
        t.objectId = ""
        localDb.add(t)
        
        //exercise
        sut.integration()
        
        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        
        
        //1件目(objectIdは共にObj1になる)
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "test1")
        XCTAssert(cloudDb.ar[0].title == "test1")
        
        
        //tearDown
    }
    
    func testIntegration_クラウドのみに存在するデータはローカルにもコピーされる(){
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //テストDBの初期化(Obj1のデータがクラウドのみに１件存在する)
        var t = Task(title: "test1",memo: "")
        t.objectId = "Obj1"
        cloudDb.add(t)
        
        //exercise
        sut.integration()
        
        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        
        
        //1件目
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "test1")
        XCTAssert(cloudDb.ar[0].title == "test1")
        
        
        //tearDown
    }

    func testIntegration_クラウド側のデータが古い場合(){
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //テストDBの初期化(クラウド側のデータが１０分古い)
        var t1 = Task(title: "CLOUD",memo: "")
        t1.objectId = "Obj1"
        t1.lastUpdate = DateTime().addMinutes(-10).nsdate!
        cloudDb.add(t1)

        var t2 = Task(title: "LOCAL",memo: "")
        t2.objectId = "Obj1"
        localDb.add(t2)
        
        //exercise
        sut.integration()
        
        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        
        
        //1件目(両方ともローカルと同じになる)
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "LOCAL")
        XCTAssert(cloudDb.ar[0].title == "LOCAL")
        
        //tearDown
    }

    
    func testIntegration_ローカル側のデータが古い場合(){
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //テストDBの初期化(ローカル側のデータが１０分古い)
        var t1 = Task(title: "CLOUD",memo: "")
        t1.objectId = "Obj1"
        cloudDb.add(t1)
        
        var t2 = Task(title: "LOCAL",memo: "")
        t2.objectId = "Obj1"
        t2.lastUpdate = DateTime().addMinutes(-10).nsdate!
        localDb.add(t2)
        
        //exercise
        sut.integration()
        
        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        
        
        //1件目(両方ともクラウドと同じになる)
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "CLOUD")
        XCTAssert(cloudDb.ar[0].title == "CLOUD")
        
        //tearDown
    }

    func testIntegration_整合がとれた状態からローカル側を更新した場合(){
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //テストDBの初期化
        var t1 = Task(title: "BEFORE",memo: "")
        cloudDb.add(t1)

        sut.integration() //一旦整合が完了した状態とする

        // クラウド側が修正される
        localDb.ar[0].lastUpdate = DateTime().addMinutes(1).nsdate!//1分後
        localDb.ar[0].title = "AFTER"
        
        //exercise
        sut.integration()
        
        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        
        
        //1件目(両方ともクラウドと同じになる)
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "AFTER")
        XCTAssert(cloudDb.ar[0].title == "AFTER")
        
        //tearDown
    }

    func testIntegration_整合がとれた状態からクラウド側を更新した場合(){
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //テストDBの初期化
        var t1 = Task(title: "BEFORE",memo: "")
        cloudDb.add(t1)
        
        sut.integration() //一旦整合が完了した状態とする
        
        // クラウド側が修正される
        cloudDb.ar[0].lastUpdate = DateTime().addMinutes(1).nsdate!//1分後
        cloudDb.ar[0].title = "AFTER"
        
        //exercise
        sut.integration()
        
        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        
        
        //1件目(両方ともクラウドと同じになる)
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "AFTER")
        XCTAssert(cloudDb.ar[0].title == "AFTER")
        
        //tearDown
    }
    
    
    func testIntegration_objectId_ローカルにデータが存在しない場合(){
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //テストDBの初期化(クラウドのみにデータが存在する)
        var t1 = Task(title: "CLOUD",memo: "")
        cloudDb.add(t1)
        let objectId = t1.objectId
        
        //exercise
        sut.integration(objectId)
        
        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        
        
        //1件目(両方ともクラウドと同じになる)
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "CLOUD")
        XCTAssert(cloudDb.ar[0].title == "CLOUD")
        
        //tearDown
    }
    
    func testIntegration_objectId_ローカルのデータが古い場合(){
        //setUp
        let sut = Repository(dbLocal: localDb,dbCloud: cloudDb)
        
        //テストDBの初期化
        var t1 = Task(title: "BEFORE",memo: "")
        cloudDb.add(t1)
        localDb.add(t1)

        // ローカルのデータを古いものにする
        t1.title = "AFTER"
        t1.lastUpdate = DateTime().addMinutes(-1).nsdate!
        localDb.ar[0] = t1
        let objectId = t1.objectId
        
        //exercise
        sut.integration(objectId)
        
        //verify
        //件数は、両方とも1件となる
        XCTAssert(localDb.count() == 1)
        XCTAssert(cloudDb.count() == 1)
        
        
        //1件目(両方ともクラウドと同じになる)
        XCTAssert(localDb.ar[0].objectId == "Obj1")
        XCTAssert(cloudDb.ar[0].objectId == "Obj1")
        XCTAssert(localDb.ar[0].title == "BEFORE")
        XCTAssert(cloudDb.ar[0].title == "BEFORE")
        
        //tearDown
    }
}
