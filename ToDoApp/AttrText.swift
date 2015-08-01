import UIKit

class AttrText {
    let str:NSMutableAttributedString
    
    init(str:String){
        self.str = NSMutableAttributedString(string: str)
    }
    // 色指定
    func setColor(color:UIColor){
        str.addAttributes([NSForegroundColorAttributeName: color], range: NSMakeRange(0, str.length))
    }
    // 打ち消し線
    func setStrike(){
        str.addAttributes([NSStrikethroughStyleAttributeName: 1], range: NSMakeRange(0, str.length))
    }
}
