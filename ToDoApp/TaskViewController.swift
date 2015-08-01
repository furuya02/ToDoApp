import UIKit

class TaskViewController: UIViewController {
    //MARK: - Data
    var task = Task(title: "Dmy",memo: "Dmy")
    var isModify = false
    
    //MARK: - Property
    
    @IBOutlet weak var buttonOk: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var toggleButtonIsDone: UIToggleButton!
    @IBOutlet weak var toggleButtonIsMark: UIToggleButton!
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textViewMemo: UITextView!
    //MARK: - View
    override func viewWillAppear(animated: Bool) {
        
        viewHeader.backgroundColor = UIColor.silverTree()
        textViewMemo.backgroundColor = UIColor.solitude()
        buttonCancel.tintColor = UIColor.whiteColor()
        buttonOk.tintColor = UIColor.whiteColor()
        
        setControl() // Data -> Control
    }
    
    
    //MARK: - setControl/getControl
    private func setControl(){
        isModify = false
        textFieldTitle.text = task.title
        textViewMemo.text = task.memo
        toggleButtonIsDone.sw = task.isDone
        toggleButtonIsMark.sw = task.isMark
    }
    
    private func getControl(){
        isModify = true // 変更あり
        task.title = textFieldTitle.text
        task.memo = textViewMemo.text
        task.isDone = toggleButtonIsDone.sw
        task.isMark = toggleButtonIsMark.sw
    }
    
    //MARK: - Action
    @IBAction func buttonSaveTapped(sender: AnyObject) {
        getControl() // Control -> Data
        performSegueWithIdentifier("unwindSegue", sender: nil)
    }
    @IBAction func toggleButtonIsDoneTapped(sender: AnyObject) {
        toggleButtonIsDone.sw = !toggleButtonIsDone.sw
    }

    @IBAction func toggleButtonIsMarkTapped(sender: AnyObject) {
        toggleButtonIsMark.sw = !toggleButtonIsMark.sw
    }
}
