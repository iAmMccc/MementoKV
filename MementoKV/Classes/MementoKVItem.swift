//
//  MementoKVItem.swift
//  MementoKV
//
//  Created by Mccc on 2025/10/30.
//

import Foundation
public class MementoKVItem {
    public var itemId: String
    public var itemObject: Any
    public var createdTime: Date
    
    public init(itemId: String, itemObject: Any, createdTime: Date) {
        self.itemId = itemId
        self.itemObject = itemObject
        self.createdTime = createdTime
    }
}
