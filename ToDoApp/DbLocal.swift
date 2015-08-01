import UIKit

// テストの際にモックに置き換えることができるようにプロトタイプで定義する
protocol DbLocal{
    func select() -> [Task]
    func insert(task: Task) -> Bool
    func search(objectId:String) -> Task?
    func delete(task: Task) -> Bool
}
