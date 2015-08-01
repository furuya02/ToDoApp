import UIKit

class MainViewController: UIViewController , UITableViewDataSource , UITableViewDelegate{
    //MARK: - Data
    var repository =  Repository(dbLocal: DbSqlite(),dbCloud: DbParse(httpClient:HttpClient()))
    
    //MARK: - Property
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: SearchView!
    @IBOutlet weak var trashView: TrashView!
    @IBOutlet weak var markView: MarkView!
    var selectedIndex : Int = -1 // TableViewの選択中のインデックス（ビュー遷移時に使用する）
    // 画面遷移後のメッセージ表示が必要な時、ここにメッセージをセットしておくと、DidAppearで処理される
    // "タイトル"¥t"メッセージ"
    private var popupMessage : String?

    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.silverTree()

        //検索・ごみ箱・マークの各ビューが閉じた時のハンドラ
        trashView.onClose = { self.setViewMode(.Normal) }
        searchView.onClose = { self.setViewMode(.Normal) }
        markView.onClose = { self.setViewMode(.Normal) }
        
        searchView.onSearch = onSearch // 検索文字列が変化した時のイベントハンドラ
        repository.setRefreshHandler({ self.tableView.reloadData() }) // 表示更新のハンドラを追加
        repository.integration() //ローカルとクラウド間のデータの整合
        setViewMode(.Normal)
        
    }
    
    override func viewDidAppear(animated: Bool) {

        if let msg = popupMessage { // 画面遷移時のエラーがセットされている場合
            var str = msg.componentsSeparatedByString("\t")
            popupMessage = nil // エラーのリセット
            if str.count == 2 {
                var ac = UIAlertController(title: str[0], message: str[1], preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(ac,animated: true,completion: nil)
            }
            
        }
    }

    //MARK: - Segue
    @IBAction func unwindTaskView(segue : UIStoryboardSegue){
        let view = segue.sourceViewController as! TaskViewController
        if view.isModify {// 修正された場合の処理
            if !repository.set(view.task) {
                //エラー発生（ポップアップメッセージ）
                popupMessage = "エラー\tデータの保存に失敗しました"
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goTaskViewSegue" {
            let view = segue.destinationViewController as! TaskViewController
            if selectedIndex == -1 { // 追加
                //ID=0のデータを渡す
                view.task = Task(title: "新しいタスク",memo: "")
            }else{ // 編集
                view.task = repository.get(selectedIndex)
            }
        }
    }
    
    // MARK: - TableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repository.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! MainTableViewCell

        cell.task = repository.get(indexPath.row)

        // 変化したアイテムの背景色をアニメーションさせる
        if repository.viewMode == ViewMode.Normal {
            if let task = cell.task {
                if task.ID == repository.newItem {
                    repository.newItem = 0 // エフェクトに使用が終わったら初期化しておく
                    cell.backgroundColor = UIColor.mySin()
                    UIView.animateWithDuration(1.5,animations: {
                        () -> Void  in
                        cell.backgroundColor = UIColor.whiteColor()
                    })
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {

        //iOS7では、無効
        let title =  repository.viewMode == .Trash ? "復活" : "削除"
        var deleteButton = UITableViewRowAction(style: .Default, title: title, handler: { (action, indexPath) in
            self.tableView.dataSource?.tableView?(
                self.tableView,
                commitEditingStyle: .Delete,
                forRowAtIndexPath: indexPath
            )
            return
        })
        deleteButton.backgroundColor = UIColor.lightCorol()
        return [deleteButton]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if repository.viewMode == .Trash {
            return // ごみ箱では、タップによる編集を受け付けない
        }
        selectedIndex = indexPath.row
        performSegueWithIdentifier("goTaskViewSegue", sender: nil)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // 削除(復活)処理
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let task = repository.get(indexPath.row)
            // 表示モードがごみ箱の時は、復活となる
            task.isDelete = repository.viewMode == ViewMode.Trash ? false : true
            repository.set(task)
            // ごみ箱モードの場合、復活処理の後、ノーマルモードに復帰する
            if repository.viewMode == .Trash {
                setViewMode(.Normal)
            }
        }
        
    }
    
    
    //MARK: - Action

    //ToolBar上のボタンのタップ
    @IBAction func buttonTapped(button: UIBarButtonItem){
        switch button.tag {
        case 0: // 検索ボタン
            setViewMode(.Search)
        case 1: // ごみ箱ボタン
            setViewMode(.Trash)
        case 2: // 重要マーク
            setViewMode(.Mark)
        default: // 追加ボタン
            setViewMode(.Normal) // ノーマルビューに戻す
            selectedIndex = -1 //追加処理の際は、番兵として−1を入れる
            performSegueWithIdentifier("goTaskViewSegue", sender: nil)
            
        }
    }
    
    // 検索文字が変化した際のイベントハンドラ
    func onSearch(searchText:String){
        repository.searchStr = searchText
    }
    
    
    // ビューの種類の変更
    func setViewMode(mode:ViewMode){
        repository.viewMode = mode
        
        searchView.visible = mode == .Search ? true : false
        trashView.visible = mode == .Trash ? true : false
        markView.visible = mode == .Mark ? true : false
        
    }
}

