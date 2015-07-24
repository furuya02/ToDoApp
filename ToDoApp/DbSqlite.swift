//
//  DbSqlite.swift
//  ToDoApp
//
//  Created by ShinichiHirauchi on 2015/07/04.
//  Copyright (c) 2015年 SAPPOROWORKS. All rights reserved.
//

import Foundation

class DbSqlite : DbLocal{
    private let tableName = "task"
    
    init(){
        let (tb,err) = SD.existingTables()
        if !contains(tb, tableName){ // テーブルが存在しない場合、ここで作成される
            //ID:BoolValは自動的に作成される
            if let err = SD.createTable(tableName,withColumnNamesAndTypes: [
                "isModify": .BoolVal,
                "objectId": .StringVal,
                "lastUpdate": .DateVal,
                "title": .StringVal,
                "memo": .StringVal,
                "isDone": .BoolVal,
                "isMark": .BoolVal,
                "isDelete": .BoolVal,
                ]){
                    println(SwiftData.errorMessageForCode(err)) // DEBUG
            }
        }
        //println(SD.databasePath()) // DEBUG データベースの物理ファイル名
    }
    
    func search(objectId:String)->Task?{
        var ar = select()
        for a in ar {
            if a.objectId == objectId {
                return a
            }
        }
        return nil
    }
    
    func select() -> [Task] {
        var ar:[Task] = []
        
        let sql = "SELECT * FROM \(tableName) ORDER BY lastUpdate DESC"
        
        let (resultSet, err) = SD.executeQuery(sql)
        if err == nil {
            for row in resultSet{
                //すべてのカラムのnilがない場合のみ有効なデータとする
                //DBから取り出す時点でunwrapperを完了している、TaskにはOptionl型は存在しない
                if let  id = row["ID"]?.asInt(),
                    objectId = row["objectId"]?.asString(),
                    lastUpdate = row["lastUpdate"]?.asDate(),
                    title = row["title"]?.asString(),
                    memo = row["memo"]?.asString(),
                    isDone = row["isDone"]?.asBool(),
                    isMark = row["isMark"]?.asBool(),
                    isDelete = row["isDelete"]?.asBool(){
                        let task = Task(title: title,memo: memo)
                        task.ID = id
                        task.objectId = objectId
                        task.lastUpdate = lastUpdate
                        task.isDone = isDone
                        task.isMark = isMark
                        task.isDelete = isDelete
                        ar.append(task)
                }
            }
        }
        return ar
    }
    
    //追加（task.ID != 0 の場合は、更新となる）
    func insert(task: Task) -> Bool{
        //INSERTの場合
        var sql = "INSERT INTO \(tableName) (objectId, lastUpdate, title, memo, isDone, isMark,isDelete) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        // UPDATEの場合
        if task.ID != 0 {
            sql = "UPDATE \(tableName) SET objectId=(?),lastUpdate=(?),title=(?),memo=(?),isDone=(?),isMark=(?),isDelete=(?) WHERE ID=\(task.ID)";
        }
        
        if let err = SD.executeChange(sql, withArgs: [
            task.objectId,
            task.lastUpdate,
            task.title,
            task.memo,
            task.isDone,
            task.isMark,
            task.isDelete
            ]) {
                return false
        }
        //新たにセットされたIDを取得する
        if task.ID == 0 {
            //lastInsertedRowID()がうまく動作していないので、直接SELECT文を使用する
            //let (id, err) = SD.lastInsertedRowID()
            let (result, err) = SD.executeQuery("SELECT MAX(ID) FROM \(tableName)")
            if err == nil {
                if let id = result[0]["MAX(ID)"]?.asInt(){
                    task.ID = id
                }
            }
        }
        return true
    }
    
    //削除
    func delete(task: Task) -> Bool{
        var sql = "DELETE FROM \(tableName) WHERE ID=\(task.ID)";
        if let err = SD.executeChange(sql) {
            return false
        }
        return true
    }
    
}
