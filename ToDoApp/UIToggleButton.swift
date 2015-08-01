
import UIKit

@IBDesignable
class UIToggleButton: UIButton {
    
    //UIButtonType.Customにする必要があります
    
    @IBInspectable var onImage : UIImage?
    @IBInspectable var offImage : UIImage?
    
    @IBInspectable var sw:Bool = false {
        didSet{
            self.setImage(sw ? onImage : offImage, forState: .Normal)
        }
    }
}


