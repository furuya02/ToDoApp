import UIKit

enum MockDbMode{
    case Local
    case Cloud
}

class MockDb {

    var ar:[Task]=[]
    var mode : MockDbMode = .Local
    var counter : Int = 1
    
    var connect:Bool = true
    
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
            if !connect { // クラウドが切断されている場合
                return;
            }
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
            if !connect { // クラウドが切断されている場合
                return;
            }
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
