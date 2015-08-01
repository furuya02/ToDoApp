import UIKit

class Repository{
    private var view : [Task] = [] // 条件に基づいて構築されたビュー
    
    // テストの際にモックに置き換えることができるようにプロトタイプで定義する
    private let dbLocal : DbLocal // ローカルDB
    private let dbCloud : DbCloud // クラウドDB
    
    // 変化したアイテム
    var newItem : Int = 0
    // 通知したアイテム
    var sendObjectId:String = ""
    
    // ビューの種類
    var viewMode : ViewMode {
        didSet{
            refreshView()// Viewの再構築
        }
    }
    // 検索文字列
    var searchStr:String{
        didSet{
            refreshView()// Viewの再構築
        }
    }
    
    init(dbLocal:DbLocal,dbCloud:DbCloud){
        self.dbLocal = dbLocal
        self.dbCloud = dbCloud
        viewMode = .Normal
        searchStr = ""
    }
    
    // 表示更新時のハンドラ
    var refreshHandler: ( ()->Void )?
    func setRefreshHandler(handler:()->Void){
        self.refreshHandler = handler
    }
    
    
    // MARK: - public function

    // viewの取得
    var count:Int{
        return view.count
    }
    // データの取得
    func get(n:Int) -> Task {
        return view[n]
    }
    
    // 新規（更新）
    func set(task:Task) -> Bool{
        
        
        enum Mode{ case Insert,Update }
        var mode = Mode.Insert
        
        task.lastUpdate = NSDate() // 更新時間の記録

        // 新規か更新かの判断
        if task.objectId != "" {
            // ローカルDBにobjectIdが存在するか
            if let t = dbLocal.search(task.objectId) {
                // 更新
                task.ID = t.ID
                mode = .Update
            }
        }

        // ローカルDBへの追加
        if !dbLocal.insert(task) {
            return false
        }

        newItem  = task.ID
        refreshView()// INSERTの場合、IDの更新も、ここで反映される
        
        // 以降は、バックグランド処理
        mode = task.objectId == "" ? .Insert : .Update
        
        // Cloudへの保存
        dbCloud.insertAsync(task,completionHandler:{
            (asyncResult) in
            if let error = asyncResult.error{
                // データ削除されていて、objectIdが見つからなかった場合
                if error.code == 101 {
                    // ローカルDBの削除処理
                    self.dbLocal.delete(task)
                    self.refreshView() // 表示更新
                }
                //その他のエラーは、そのまま返す
            }else{
                
                
                
                //INSERTの場合、ローカルのDBのobjectIdを更新する
                if mode == .Insert {
                    if let t = asyncResult.val! {
                        task.objectId = t.objectId
                        self.dbLocal.insert(task)
                        self.refreshView()
                    }
                }
                self.sendObjectId = task.objectId // 自ら通知したデータは、更新処理の対象外とするために記憶する
                self.dbCloud.sendPush(task.objectId) // 通知の送信
            }
        })
        return true
    }
    
    //整合処理（通知時の処理）
    func integration(objectId:String){
        
        // 自分が送信した通知の場合は、処理なし
        if sendObjectId == objectId {
            sendObjectId = ""
            return
        }
        
        
        dbCloud.selectAsync(objectId,completionHandler: {
            (asyncResult) in
            if let error = asyncResult.error {
                // 読み込みに失敗した場合は、継続しない
            }else{
                if let ar = asyncResult.val {
                    if ar.count == 1 {
                        let ct = ar[0]
                        // ローカル側に同じデータがあるか
                        if let lt = self.search(self.dbLocal.select(), objectId: objectId) {
                            ct.ID = lt.ID
                        }
                        self.dbLocal.insert(ct)
                        self.newItem  = ct.ID
                        self.refreshView()// INSERTの場合、IDの更新も、ここで反映される
                    }
                }
            }
        })
    }

    
    
    //整合処理（起動時の処理）
    func integration(){
        //ローカルの一覧取得
        var localTasks = dbLocal.select()
        // クラウドの一覧取得
        dbCloud.selectAsync(nil,completionHandler: {
            (asyncResult) in
            if let error = asyncResult.error {
                // 読み込みに失敗した場合は、継続しない
            }else{
                if let cloudTasks = asyncResult.val {
                    // 両方のデータが揃った時点で、本番処理
                    self.integration(localTasks, cloudTasks:cloudTasks)
                }
            }
        })
        refreshView() // 再表示
    }
    
    // push通知の登録
    func installPush(deviceToken:String){
        self.dbCloud.installPush(deviceToken)
    }
    
    // push通知の登録削除
    func uninstallPush(){
        self.dbCloud.uninstallPush()
    }

    // MARK: - private function

    //整合処理（本番処理）
    private func integration(localTasks : [Task], cloudTasks: [Task]){

        // （前段処理）クラウドデータの全件確認
        for ct in cloudTasks {
            // ローカル側に同じobjectIdが存在するか
            if let  lt = search(localTasks, objectId: ct.objectId) { // 存在する場合
                // 比較処理
                comparison(lt ,cloudTask:ct)
            }else{ // 存在しない場合
                // ローカルDBへの追加
                dbLocal.insert(ct)
                self.refreshView()
            }
        }
        // （後段処理）ローカルデータの全件確認
        for lt in localTasks {
            // クラウド側に同じデータがあるか
            let  ct = search(cloudTasks, objectId: lt.objectId)
            if ct == nil { // ない場合
                if lt.objectId != "" {
                    // クラウド側にデータがない場合は、このobjectIdは無効
                    // ローカルデータの削除
                    dbLocal.delete(lt)
                    refreshView()
                }else{
                    // クラウド側の更新
                    dbCloud.insertAsync(lt,completionHandler:{
                        (asyncResult) in
                        if let error = asyncResult.error{
                            //エラーは、放置する（次回処理）
                        }else{
                            // ローカルDBのobejctIdの更新
                            self.dbLocal.insert(lt)
                            self.refreshView()
                        }
                    })
                    
                }
            }
        }
    }


    // 比較処理
    private func comparison(localTask: Task,cloudTask:Task){

        if localTask.compare(cloudTask) {
            return // データに相違がない場合は、作業完了
        }

        var lt = DateTime(nsdate: localTask.lastUpdate)
        var ct = DateTime(nsdate: cloudTask.lastUpdate)

        if lt.ticks < ct.ticks { // クラウド側のデータの方が新しい場合
            cloudTask.ID = localTask.ID // ローカルの同一データを更新する
            dbLocal.insert(cloudTask)
            refreshView()
        }else{ // ローカルの方が新しい場合
            dbCloud.insertAsync(localTask,completionHandler:{
                (asyncResult) in
                if let error = asyncResult.error{
                    //エラー時は、そのまま返す
                }
            })
        }
    }

    // localDBからselectして、条件に基づいてviewを初期化する
    private func refreshView(){
        
        // 条件に基づくviewの再構築
        self.view = []

        //localDBからselect
        var tasks = dbLocal.select()
        
        if viewMode == .Search {
            var ar:[Task]=[]
            for a in tasks {
                // isDelete=falseであり、かつ、検索も文字列を含むものだけ抽出する
                if !a.isDelete {
                    var index = a.title.rangeOfString(searchStr)
                    if index != nil {
                        ar.append(a)
                    }else{
                        var index = a.memo.rangeOfString(searchStr)
                        if index != nil {
                            ar.append(a)
                        }
                    }
                }
            }
            tasks = ar
        } else if viewMode == .Trash{ // ごみ箱
            var ar:[Task]=[]
            for a in tasks {
                if a.isDelete { // isDelete=true のものだけを抽出する
                    ar.append(a)
                }
            }
            tasks = ar
        } else if viewMode == .Normal{ // ノーマル
            var ar:[Task]=[]
            for a in tasks {
                if !a.isDelete { // isDelete=false のものだけを抽出する
                    ar.append(a)
                }
            }
            tasks = ar
        } else if viewMode == .Mark{ // 重要マーク
            var ar:[Task]=[]
            for a in tasks {
                if !a.isDelete && a.isMark { // isDelete=false かつ isMark=true のものだけを抽出する
                    ar.append(a)
                }
            }
            tasks = ar
        }
        
        
        // 前段で未完了(!isDone)のみ取り出す
        for n in tasks {
            if !n.isDone {
                self.view.append(n)
            }
        }
        // 後段で完了のみ取り出す
        for n in tasks {
            if n.isDone {
                self.view.append(n)
            }
        }
        // 表示更新のメッセージ送信
        if let f = refreshHandler { f() } // 表示更新
    }

    
    private func search(tasks :[Task], objectId : String) -> Task? {
        var tt = tasks.filter( {$0.objectId == objectId} ).first
        
        for t in tasks {
            if t.objectId == objectId {
                return t
            }
        }
        return nil
    }
}
