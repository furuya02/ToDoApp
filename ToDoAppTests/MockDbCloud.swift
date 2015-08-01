import UIKit

class MockDbCloud : MockDb,DbCloud{
    
    override init(){
        super.init()
        mode = .Cloud
    }
    

    func selectAsync(objectId:String?,completionHandler: (_:AsyncResult<[Task]>) -> Void){
        completionHandler(AsyncResult<[Task]>(ar))
    }

    func insertAsync(task: Task,completionHandler: (_:AsyncResult<Task?>)->Void){
        add(task)
        if(ar.count>0){
            completionHandler(AsyncResult<Task?>(ar[ar.count-1]))
        }else{
            completionHandler(AsyncResult<Task?>(NSError()))
        }
    }

    func deleteAsync(task: Task,completionHandler: (_:AsyncResult<Task?>)->Void){
        del(task)
    }
    
    func installPush(deviceToken:String){}
    func uninstallPush(){}
    func sendPush(objectId:String){}


    
}
