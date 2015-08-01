import UIKit

//非同期メソッドの戻り値を定型化するために定義
//error：NSError?が　nil かどうかでエラー発生の有無を表現する
class AsyncResult<T>{
    var error:NSError?
    var val:T? = nil
    init(_ val:T){ // 正常終了の場合のイニシャライザ
        self.val = val
    }
    init(_ error:NSError){ // エラーの場合のイニシャライザ
        self.error = error
    }
}

//typealias TaskResult =  AsyncResult<Task?>
//typealias TaskHandler = (_:TaskResult) -> Void

