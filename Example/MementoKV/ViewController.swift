//
//  ViewController.swift
//  MementoKV
//
//  Created by iAmMccc on 10/30/2025.
//  Copyright (c) 2025 iAmMccc. All rights reserved.
//

import UIKit
import MementoKV


class ViewController: UIViewController {

    let kvStore = MementoKV()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableName = "AlarmTable"
        
        // 1. 创建表
        kvStore.createTable(named: tableName)
        
        // 2. 插入数据
        let alarmData: [String: Any] = [
            "title": "Morning Alarm",
            "time": "07:30",
            "enabled": true
        ]
        kvStore.putObject(alarmData, withId: "alarm_001", into: tableName)
        
        // 插入字符串
        kvStore.putString("Hello MementoKV", withId: "greeting", into: tableName)
        
        // 插入数字
        kvStore.putNumber(NSNumber(value: 42), withId: "answer", into: tableName)
        
        // 3. 查询数据
        if let alarm = kvStore.getObject(byId: "alarm_001", from: tableName) as? [String: Any] {
            print("Alarm:", alarm)
        }
        
        if let greeting = kvStore.getString(byId: "greeting", from: tableName) {
            print("Greeting:", greeting)
        }
        
        if let answer = kvStore.getNumber(byId: "answer", from: tableName) {
            print("Answer:", answer)
        }
        
        // 4. 获取所有 items
        if let allItems = kvStore.getAllItems(from: tableName) {
            print("All items in table:")
            for item in allItems {
                print(item.itemId, item.itemObject, item.createdTime)
            }
        }
        
        // 5. 获取表中数量
        let count = kvStore.getCount(from: tableName)
        print("Total items in table:", count)
//        
//        // 6. 删除单个 item
//        kvStore.deleteObject(byId: "greeting", from: tableName)
//        
//        // 7. 删除多个 item
//        kvStore.deleteObjects(byIds: ["alarm_001", "answer"], from: tableName)
//        
//        // 8. 删除前缀 item
//        kvStore.putString("Test1", withId: "test_001", into: tableName)
//        kvStore.putString("Test2", withId: "test_002", into: tableName)
//        kvStore.deleteObjects(byPrefix: "test_", from: tableName)
//        
//        // 9. 清空表
//        kvStore.clearTable(tableName)
//        
//        // 10. 删除表
//        kvStore.dropTable(tableName)
//        
//        // 11. 关闭数据库
//        kvStore.close()
    }
}
