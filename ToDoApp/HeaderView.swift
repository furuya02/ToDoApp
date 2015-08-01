import UIKit

class HeaderView: UIView {

    private var layoutConstraintHeight : NSLayoutConstraint! // 高さの制約
    private var buttonCancel : UIButton? // キャンセルボタン
    private let height:CGFloat = 45 // 表示時の高さ
    
    var onClose:(()->Void)? // キャンセルボタンが押された時のイベントハンドラ

    required init(coder aDecoder: NSCoder) {
        
        visible = false // 非表示
        super.init(coder: aDecoder)
        
        // サブビューの検索
        for childView in subviews {
            if let v = childView as? UIButton {
                buttonCancel = v
            }
        }
        // 制約の検索
        for c in constraints() {
            if let f = c.firstItem as? UIView {
                if c.secondItem! == nil && c.constant == height {
                    layoutConstraintHeight = c as! NSLayoutConstraint
                    break
                }
            }
        }
        
        //キャンセルがタップされた際のハンドラ
        buttonCancel!.addTarget(self, action: "buttonCancelTapped:", forControlEvents: .TouchUpInside)
    }

    // キャンセルボタン
    func buttonCancelTapped(sender: UIButton) {
        visible = false
        if onClose != nil {
            onClose!()
        }
    }
    
    
    // 表示・非表示
    var visible : Bool {
        didSet{
            if visible {
                // Viewの高さの制約をheightに設定する
                layoutConstraintHeight.constant = height
                self.hidden = false
                superview?.backgroundColor = UIColor.solitude()
            }else{
                layoutConstraintHeight.constant = 0
                self.hidden = true
                endEditing(true)
                superview?.backgroundColor = UIColor.silverTree()
            }
        }
    }

    
}
