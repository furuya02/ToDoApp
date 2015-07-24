//
//  Repository.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/04.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import Foundation

class Repository{
    private var view : [Task] = [] // 条件に基づいて構築されたビュー
    
    // テストの際にモックに置き換えることができるようにプロトタイプで定義する
    private let dbLocal : DbLocal // ローカルDB
    private let dbCloud : DbCloud // クラウドDB
    
    // 変化したアイテム
    var newItem : Int = 0
    
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
    func setAsync(task:Task,completeHandler:(_:AsyncResult<Task?>) -> Void){
        
        
        enum Mode{ case Insert,Update }
        var mode = Mode.Insert
        
        task.lastUpdate = NSDate() // 更新時間の記録
        // ローカルDBにobjectIdが存在するか
        if let t = dbLocal.search(task.objectId) {
            // 存在する場合は、更新処理となる
            task.ID = t.ID
            mode = .Update
        }else{
            // 存在しない場合は、追加処理となる
            task.ID = 0
        }
        // ローカルDBへの追加
        if !dbLocal.insert(task) {
            //エラー時は、NSErrorを生成して返す(code=99によってポップアップのエラーが表示される)
            var error = NSError(domain: "SQLite Insert Error", code: 99, userInfo: nil)
            completeHandler(AsyncResult(error))
            return
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
            }
            
            // 同期を頻繁に行う場合
            // クラウドとの通信に成功している場合、ここで整合処理を実施する
            // 負荷が上がるので、将来、通知方式に修正する
            self.integration()
            
        })
        
    }
    
    //整合処理（データ取得）
    func integration(){
        //ローカルの一覧取得
        var localTasks = dbLocal.select()
        // クラウドの一覧取得
        dbCloud.selectAsync({
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