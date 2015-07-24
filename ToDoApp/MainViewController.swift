//
//  ViewController.swiftƒ
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/04.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

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
        //trashView.onClose = onCloseHeaderView
        searchView.onClose = onCloseHeaderView
        markView.onClose = onCloseHeaderView 
        
        searchView.onSearch = onSearch // 検索文字列が変化した時のイベントハンドラ
        repository.setRefreshHandler(refresh) // 表示更新のハンドラを追加
        repository.integration() //ローカルとクラウド間のデータの整合
        
        setViewMode(.Normal)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            repository.setAsync(view.task,completeHandler: completeHandler) //ID==0はINSERTされ、ID!=0はUPDATEされる
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
            repository.setAsync(task,completeHandler: completeHandler)
            // ごみ箱モードの場合、復活処理の後、ノーマルモードに復帰する
            if repository.viewMode == .Trash {
                setViewMode(.Normal)
            }
        }
        
    }
    
    
    //MARK: - Action
    //追加
    @IBAction func buttonAddTapped(sender: AnyObject) {
        setViewMode(.Normal) // ノーマルビューに戻す
        selectedIndex = -1 //追加処理の際は、番兵として−1を入れる
        performSegueWithIdentifier("goTaskViewSegue", sender: nil)
    }

    // ごみ箱ボタン
    @IBAction func buttonTrashTapped(sender: AnyObject) {
        setViewMode(.Trash)
    }
    // 重要ボタン
    @IBAction func buttonIsMarkTapped(sender: AnyObject) {
        setViewMode(.Mark)
    }
    // 検索ボタン
    @IBAction func buttonSearchTapped(sender: AnyObject) {
        setViewMode(.Search)
    }
    
    // 検索/ごみ箱ビューが閉じる時のイベントハンドラ
    func onCloseHeaderView(){
        setViewMode(.Normal) // ノーマルビューに戻す
    }
    
    // 検索文字が変化した際のイベントハンドラ
    func onSearch(searchText:String){
        repository.searchStr = searchText
    }
    

    // DB操作完了時のコールバック
    private func completeHandler(asyncResult:AsyncResult<Task?>){
        if let error = asyncResult.error {
            if error.code == 101 {
                //エラー発生（ポップアップメッセージ）
                popupMessage = "エラー\tデータの保存に失敗しました"
                
            }
        }else{
            refresh() // TableViewの表示更新
            // クラウドとの通信に成功している場合は、バックグランドで整合処理も行う
            repository.integration() //ローカルとクラウド間のデータの整合
        }
    }
    // ビューの種類の変更
    func setViewMode(mode:ViewMode){
        repository.viewMode = mode
        searchView.visible = mode == .Search ? true : false
        trashView.visible = mode == .Trash ? true : false
        markView.visible = mode == .Mark ? true : false
        
    }

    // TableViewの表示更新
    func refresh() {
        tableView.reloadData()
    }

}

