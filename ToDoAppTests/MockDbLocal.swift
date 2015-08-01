//
import UIKit

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