# MementoKV

一个轻量级的 iOS 本地键值存储库，基于 **FMDB** 封装，支持存储 JSON 对象、字符串、数字等多种类型，并提供增删改查（CRUD）功能。

特点：

- 轻量级，无需依赖 Codable
- 支持任意 JSON 对象存储
- 支持批量删除和按前缀删除
- 提供表操作接口：创建、删除、清空、判断表是否存在
- 提供详细创建时间记录
- 支持安全的数据库队列操作



## 功能

### 表操作

- `createTable(named:)` - 创建表
- `isTableExists(_:)` - 判断表是否存在
- `clearTable(_:)` - 清空表中数据
- `dropTable(_:)` - 删除表

### 数据存储（Put）

- `putObject(_:withId:into:)` - 存储任意 JSON 对象
- `putString(_:withId:into:)` - 存储字符串
- `putNumber(_:withId:into:)` - 存储数字

### 数据获取（Get）

- `getObject(byId:from:)` - 获取任意对象
- `getMementoKVItem(byId:from:)` - 获取完整对象（含 id、对象、创建时间）
- `getString(byId:from:)` - 获取字符串
- `getNumber(byId:from:)` - 获取数字
- `getAllItems(from:)` - 获取表中所有数据
- `getCount(from:)` - 获取表中数据条数

### 数据删除（Delete）

- `deleteObject(byId:from:)` - 删除单条数据
- `deleteObjects(byIds:from:)` - 批量删除
- `deleteObjects(byPrefix:from:)` - 按前缀删除

### 数据库关闭

- `close()` - 关闭数据库连接



## 安装

### CocoaPods

```
pod 'MementoKV'
```



## 使用示例

```
import MementoKV

// 初始化
let kv = MementoKV(withName: "myDatabase.sqlite")

// 创建表
kv.createTable(named: "alarm_table")

// 存储数据
kv.putString("闹钟内容", withId: "alarm_1", into: "alarm_table")
kv.putNumber(10, withId: "alarm_count", into: "alarm_table")
kv.putObject(["time": "08:00", "repeat": true], withId: "alarm_detail", into: "alarm_table")

// 获取数据
let str = kv.getString(byId: "alarm_1", from: "alarm_table")
let num = kv.getNumber(byId: "alarm_count", from: "alarm_table")
let obj = kv.getObject(byId: "alarm_detail", from: "alarm_table")

// 删除数据
kv.deleteObject(byId: "alarm_1", from: "alarm_table")

// 获取表数据条数
let count = kv.getCount(from: "alarm_table")

// 关闭数据库
kv.close()
```



## 注意事项

- 存储的数据应为可序列化的 JSON 对象
- 数据库操作是基于 **FMDatabaseQueue**，线程安全
- 表名不能包含空格或为空



## 贡献

欢迎提交 Issue 或 Pull Request，如果你有更好的优化或功能扩展，也可以 fork 后提交。

