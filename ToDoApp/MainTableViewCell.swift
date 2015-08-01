import UIKit

class MainTableViewCell: UITableViewCell {

    //MARK: - Property
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelMemo: UILabel!
    @IBOutlet weak var labelLastUpdate: UILabel!
    @IBOutlet weak var toggleButtonIsMark: UIToggleButton!
    var task : Task? {
        
        didSet{

            if let t = task as Task? {
                
                let title = AttrText(str: t.title)
                //Memo(改行は空白で表示する)
                let memo = AttrText(str: t.memo.stringByReplacingOccurrencesOfString("\n", withString: " "))
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                let lastUpdate = AttrText(str: dateFormatter.stringFromDate(t.lastUpdate))
                

                var color = UIColor.blackBlock()
                if t.isDelete {
                    color = UIColor.lightCorol()
                }else if t.isDone {
                    color = UIColor.veryLightGrey()
                }
                title.setColor(color)
                memo.setColor(color)
                lastUpdate.setColor(color)
                toggleButtonIsMark.enabled = true

                if t.isDone {
                    title.setStrike()
                    memo.setStrike()
                    lastUpdate.setStrike()
                    toggleButtonIsMark.enabled = false
                }
                
                labelTitle.attributedText = title.str
                labelMemo.attributedText = memo.str
                labelLastUpdate.attributedText = lastUpdate.str
                toggleButtonIsMark.sw = t.isMark
                
            }
        }
        
    }

}
