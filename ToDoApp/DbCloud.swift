import UIKit

// テストの際にモックに置き換えることができるようにプロトタイプで定義する
protocol DbCloud{
    func selectAsync(objectId:String?,completionHandler: (_:AsyncResult<[Task]>) -> Void)
    func insertAsync(task: Task,completionHandler: (_:AsyncResult<Task?>)->Void)
    func deleteAsync(task: Task,completionHandler: (_:AsyncResult<Task?>)->Void)
    func installPush(deviceToken:String)
    func uninstallPush()
    func sendPush(objectId:String)

}