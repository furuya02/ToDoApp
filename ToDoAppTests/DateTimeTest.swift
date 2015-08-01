import UIKit
import XCTest

class DateTimeTest: XCTestCase {

    func testTicksによる初期化(){
        //setUp
        let sut = DateTime(ticks: 60)// 1970/01/01から60秒後
        let expected = "1970/01/01 09:01:00"
        
        //exercise
        var actual = sut.toString()
        
        //verify
        XCTAssert(actual == expected)
        
        //tearDown
    }

    func testTicksプロパティ(){
        //setUp
        let ticks:Int64 = 60
        let sut = DateTime(ticks: ticks) //1970/01/01 0900 + ticks秒で初期化
        let expected = ticks

        //exercise
        var actual = sut.ticks
        
        //verify
        XCTAssert(actual == expected)
        
        //tearDown
        
    }
    
    //AddYead AddMonth AddDay AddHour AddSec は、内部実装が同じなので、このテストで兼ねる
    func testAddminute(){
        var params :[(String,Int,String?)] = [
            ("2010/01/01 00:00:00",10,"2010/01/01 00:10:00"),
            ("2010/01/01 00:00:00",70,"2010/01/01 01:10:00"), // 繰り上がり 00:00 +70 01:10
            ("2010/01/01 00:10:00",-10,"2010/01/01 00:00:00"),// マイナス
            ("2010/01/01 01:10:00",-20,"2010/01/01 00:50:00"),// 繰り下がり 01:10 -20 00:50
         ]
        
        for (before,minute,expected) in params {
            
            //setUp
            let sut = DateTime()
            sut.fromString(before)
            //exercise
            sut.addMinutes(minute)
            var actual = sut.toString()
            
            //verify
            XCTAssert(actual == expected)
            
            //tearDown
        }
    }

    func testToString_年月日(){
        var params :[(Int,Int,Int,String?)] = [
            (2010,1,1,"2010/01/01 00:00:00"),
            (2010,10,10,"2010/10/10 00:00:00"),
            (1000,12,31,"1000/12/31 00:00:00"),
        ]
        
        for (year,month,day,expected) in params {
            
            //setUp
            let sut = DateTime(year: year,month: month,day: day)
            
            //exercise
            var actual = sut.toString()
            
            //verify
            XCTAssert(actual == expected)
            
            //tearDown
        }
    }
    
    func testToString_時分秒(){
        // 2010.01.01は固定
        var params :[(Int,Int,Int,String?)] = [
            (0,0,0,"2010/01/01 00:00:00"),
            (10,10,10,"2010/01/01 10:10:10"),
            (23,59,59,"2010/01/01 23:59:59"),
        ]
        
        for (hour,minute,sec,expected) in params {
            
            //setUp
            let sut = DateTime(year: 2010,month: 1,day: 1,hour: hour,minute: minute,sec: sec)
            
            //exercise
            var actual = sut.toString()
            
            //verify
            XCTAssert(actual == expected)
            
            //tearDown
        }
    }
    
    func testToString_フォーマット(){
        // 2010.01.01 01:01:01 は固定
        var params :[(String,String)] = [
            ("yyyy/MM/dd HH:mm:ss","2010/01/01 01:01:01"),
        ]
        
        for (format,expected) in params {
            
            //setUp
            let sut = DateTime(year: 2010,month: 1,day: 1,hour: 1,minute: 1,sec: 1)
            
            //exercise
            var actual = sut.toString(format)
            
            //verify
            XCTAssert(actual == expected)
            
            //tearDown
        }
    }

}
