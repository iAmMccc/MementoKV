import Foundation
import FMDB

/// MementoKV：轻量级本地键值存储，支持 JSON 对象、字符串、数字等类型存储
public class MementoKV {

    /// 数据库操作队列
    private var dbQueue: FMDatabaseQueue?
    
    /// 默认数据库名称
    private static let DEFAULT_DB_NAME = "database.sqlite"
    
    // MARK: - SQL 模板
    
    /// 创建表 SQL 模板
    private static let CREATE_TABLE_SQL = """
    CREATE TABLE IF NOT EXISTS %@ (
    id TEXT NOT NULL PRIMARY KEY,
    json TEXT NOT NULL,
    createdTime TEXT NOT NULL
    )
    """
    
    /// 插入或替换数据 SQL 模板
    private static let UPDATE_ITEM_SQL = "REPLACE INTO %@ (id, json, createdTime) values (?, ?, ?)"
    
    /// 查询单条数据 SQL 模板
    private static let QUERY_ITEM_SQL = "SELECT json, createdTime FROM %@ WHERE id = ? LIMIT 1"
    
    /// 查询所有数据 SQL 模板
    private static let SELECT_ALL_SQL = "SELECT * FROM %@"
    
    /// 统计数据条数 SQL 模板
    private static let COUNT_ALL_SQL = "SELECT count(*) AS num FROM %@"
    
    /// 清空表数据 SQL 模板
    private static let CLEAR_ALL_SQL = "DELETE FROM %@"
    
    /// 删除单条数据 SQL 模板
    private static let DELETE_ITEM_SQL = "DELETE FROM %@ WHERE id = ?"
    
    /// 批量删除 SQL 模板
    private static let DELETE_ITEMS_SQL = "DELETE FROM %@ WHERE id IN ( %@ )"
    
    /// 按前缀删除 SQL 模板
    private static let DELETE_ITEMS_WITH_PREFIX_SQL = "DELETE FROM %@ WHERE id LIKE ?"
    
    /// 删除表 SQL 模板
    private static let DROP_TABLE_SQL = "DROP TABLE %@"
    
    /// 日期格式化器，ISO8601 格式
    private let dateFormatter: ISO8601DateFormatter = ISO8601DateFormatter()
    
    // MARK: - 初始化
    
    /// 默认初始化，使用默认数据库名称
    public init() { _initDB(withName: MementoKV.DEFAULT_DB_NAME) }
    
    /// 使用指定数据库名称初始化
    public init(withName dbName: String) { _initDB(withName: dbName) }
    
    /// 使用指定数据库路径初始化
    public init(withPath dbPath: String) { _initDB(withPath: dbPath) }
}

// MARK: - 公共接口
public extension MementoKV {
    
    // MARK: - 表操作
    
    /// 创建表
    func createTable(named tableName: String) { _createTable(named: tableName) }
    
    /// 获取数据库路径
    var dbPath: String? { dbQueue?.path }
    
    /// 判断表是否存在
    func isTableExists(_ tableName: String) -> Bool { _isTableExists(tableName) }
    
    /// 清空表数据
    func clearTable(_ tableName: String) { _clearTable(tableName) }
    
    /// 删除表
    func dropTable(_ tableName: String) { _dropTable(tableName) }
    
    // MARK: - 存储方法
    
    /// 存储任意 JSON 对象
    func putObject(_ object: Any, withId objectId: String, into tableName: String) { _putObject(object, withId: objectId, into: tableName) }
    
    /// 存储字符串
    func putString(_ string: String, withId stringId: String, into tableName: String) { _putString(string, withId: stringId, into: tableName) }
    
    /// 存储数字
    func putNumber(_ number: NSNumber, withId numberId: String, into tableName: String) { _putNumber(number, withId: numberId, into: tableName) }
    
    // MARK: - 获取方法
    
    /// 获取任意对象
    func getObject(byId objectId: String, from tableName: String) -> Any? { _getObject(byId: objectId, from: tableName) }
    
    /// 获取完整 MementoKVItem（包含 id、对象、创建时间）
    func getMementoKVItem(byId objectId: String, from tableName: String) -> MementoKVItem? { _getMementoKVItem(byId: objectId, from: tableName) }
    
    /// 获取字符串
    func getString(byId stringId: String, from tableName: String) -> String? { _getString(byId: stringId, from: tableName) }
    
    /// 获取数字
    func getNumber(byId numberId: String, from tableName: String) -> NSNumber? { _getNumber(byId: numberId, from: tableName) }
    
    /// 获取表中所有数据
    func getAllItems(from tableName: String) -> [MementoKVItem]? { _getAllItems(from: tableName) }
    
    /// 获取表中数据条数
    func getCount(from tableName: String) -> Int { _getCount(from: tableName) }
    
    // MARK: - 删除方法
    
    /// 删除单条数据
    func deleteObject(byId objectId: String, from tableName: String) { _deleteObject(byId: objectId, from: tableName) }
    
    /// 批量删除数据
    func deleteObjects(byIds objectIds: [String], from tableName: String) { _deleteObjects(byIds: objectIds, from: tableName) }
    
    /// 按前缀删除数据
    func deleteObjects(byPrefix prefix: String, from tableName: String) { _deleteObjects(byPrefix: prefix, from: tableName) }
    
    // MARK: - 关闭数据库
    
    /// 关闭数据库连接
    func close() { _close() }
}

// MARK: - Private Implementation
fileprivate extension MementoKV {
    
    func _initDB(withName dbName: String) {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let dbPath = (documents as NSString).appendingPathComponent(dbName)
        dbQueue = FMDatabaseQueue(path: dbPath)
        if dbQueue == nil { print("ERROR: Failed to initialize database at path: \(dbPath)") }
    }
    
    func _initDB(withPath dbPath: String) {
        dbQueue = FMDatabaseQueue(path: dbPath)
        if dbQueue == nil { print("ERROR: Failed to initialize database at path: \(dbPath)") }
    }
    
    static func _checkTableName(_ tableName: String) -> Bool {
        if tableName.isEmpty || tableName.contains(" ") {
            print("ERROR: table name '\(tableName)' format error.")
            return false
        }
        return true
    }
    
    // MARK: - Table Operations
    func _createTable(named tableName: String) {
        guard MementoKV._checkTableName(tableName), let dbQueue = dbQueue else { return }
        let sql = String(format: MementoKV.CREATE_TABLE_SQL, tableName)
        dbQueue.inDatabase { db in
            do { try db.executeUpdate(sql, values: []) }
            catch { print("ERROR: Failed to create table '\(tableName)': \(error)") }
        }
    }
    
    func _isTableExists(_ tableName: String) -> Bool {
        guard MementoKV._checkTableName(tableName), let dbQueue = dbQueue else { return false }
        var exists = false
        dbQueue.inDatabase { db in exists = db.tableExists(tableName) }
        return exists
    }
    
    func _clearTable(_ tableName: String) {
        guard MementoKV._checkTableName(tableName), let dbQueue = dbQueue else { return }
        let sql = String(format: MementoKV.CLEAR_ALL_SQL, tableName)
        dbQueue.inDatabase { db in
            do { try db.executeUpdate(sql, values: []) }
            catch { print("ERROR: Failed to clear table '\(tableName)': \(error)") }
        }
    }
    
    func _dropTable(_ tableName: String) {
        guard MementoKV._checkTableName(tableName), let dbQueue = dbQueue else { return }
        let sql = String(format: MementoKV.DROP_TABLE_SQL, tableName)
        dbQueue.inDatabase { db in
            do { try db.executeUpdate(sql, values: []) }
            catch { print("ERROR: Failed to drop table '\(tableName)': \(error)") }
        }
    }
    
    // MARK: - Put Methods
    func _putObject(_ object: Any, withId objectId: String, into tableName: String) {
        guard MementoKV._checkTableName(tableName), let dbQueue = dbQueue else { return }
        guard JSONSerialization.isValidJSONObject(object) else { print("ERROR: Invalid JSON object"); return }
        do {
            let data = try JSONSerialization.data(withJSONObject: object, options: [])
            guard let jsonString = String(data: data, encoding: .utf8) else { print("ERROR: Failed to convert data to string"); return }
            let createdTimeString = dateFormatter.string(from: Date())
            let sql = String(format: MementoKV.UPDATE_ITEM_SQL, tableName)
            dbQueue.inDatabase { db in
                do { try db.executeUpdate(sql, values: [objectId, jsonString, createdTimeString]) }
                catch { print("ERROR: Failed to insert/replace item '\(objectId)' into '\(tableName)': \(error)") }
            }
        } catch { print("ERROR: Failed to serialize JSON: \(error)") }
    }
    
    func _putString(_ string: String, withId stringId: String, into tableName: String) {
        _putObject([string], withId: stringId, into: tableName)
    }
    
    func _putNumber(_ number: NSNumber, withId numberId: String, into tableName: String) {
        _putObject([number], withId: numberId, into: tableName)
    }
    
    // MARK: - Get Methods
    func _getObject(byId objectId: String, from tableName: String) -> Any? {
        return _getMementoKVItem(byId: objectId, from: tableName)?.itemObject
    }
    
    func _getMementoKVItem(byId objectId: String, from tableName: String) -> MementoKVItem? {
        guard MementoKV._checkTableName(tableName), let dbQueue = dbQueue else { return nil }
        let sql = String(format: MementoKV.QUERY_ITEM_SQL, tableName)
        var jsonString: String?
        var createdTime: Date?
        dbQueue.inDatabase { db in
            do {
                let rs = try db.executeQuery(sql, values: [objectId])
                defer { rs.close() }
                if rs.next() {
                    jsonString = rs.string(forColumn: "json")
                    if let timeStr = rs.string(forColumn: "createdTime") {
                        createdTime = dateFormatter.date(from: timeStr)
                    }
                }
            } catch { print("ERROR: Failed to query item '\(objectId)' from '\(tableName)': \(error)") }
        }
        if let jsonString, let createdTime {
            do {
                let object = try JSONSerialization.jsonObject(with: Data(jsonString.utf8), options: [.allowFragments])
                return MementoKVItem(itemId: objectId, itemObject: object, createdTime: createdTime)
            } catch { print("ERROR: Failed to parse JSON for item '\(objectId)': \(error)") }
        }
        return nil
    }
    
    func _getString(byId stringId: String, from tableName: String) -> String? {
        if let array = _getObject(byId: stringId, from: tableName) as? [Any], let str = array.first as? String {
            return str
        }
        return nil
    }
    
    func _getNumber(byId numberId: String, from tableName: String) -> NSNumber? {
        if let array = _getObject(byId: numberId, from: tableName) as? [Any], let num = array.first as? NSNumber {
            return num
        }
        return nil
    }
    
    func _getAllItems(from tableName: String) -> [MementoKVItem]? {
        guard MementoKV._checkTableName(tableName), let dbQueue = dbQueue else { return nil }
        let sql = String(format: MementoKV.SELECT_ALL_SQL, tableName)
        var result = [MementoKVItem]()
        dbQueue.inDatabase { db in
            do {
                let rs = try db.executeQuery(sql, values: [])
                defer { rs.close() }
                while rs.next() {
                    guard let itemId = rs.string(forColumn: "id"),
                          let jsonString = rs.string(forColumn: "json"),
                          let createdTimeStr = rs.string(forColumn: "createdTime"),
                          let createdTime = dateFormatter.date(from: createdTimeStr) else { continue }
                    let item = MementoKVItem(itemId: itemId, itemObject: jsonString, createdTime: createdTime)
                    result.append(item)
                }
            } catch { print("ERROR: Failed to query all items from '\(tableName)': \(error)") }
        }
        for item in result {
            if let jsonString = item.itemObject as? String {
                if let object = try? JSONSerialization.jsonObject(with: Data(jsonString.utf8), options: [.allowFragments]) {
                    item.itemObject = object
                }
            }
        }
        return result
    }
    
    func _getCount(from tableName: String) -> Int {
        guard MementoKV._checkTableName(tableName), let dbQueue = dbQueue else { return 0 }
        let sql = String(format: MementoKV.COUNT_ALL_SQL, tableName)
        var count = 0
        dbQueue.inDatabase { db in
            do {
                let rs = try db.executeQuery(sql, values: [])
                defer { rs.close() }
                if rs.next() { count = Int(rs.int(forColumn: "num")) }
            } catch { print("ERROR: Failed to count items in '\(tableName)': \(error)") }
        }
        return count
    }
    
    // MARK: - Delete Methods
    func _deleteObject(byId objectId: String, from tableName: String) {
        guard MementoKV._checkTableName(tableName), let dbQueue = dbQueue else { return }
        let sql = String(format: MementoKV.DELETE_ITEM_SQL, tableName)
        dbQueue.inDatabase { db in
            do { try db.executeUpdate(sql, values: [objectId]) }
            catch { print("ERROR: Failed to delete item '\(objectId)' from '\(tableName)': \(error)") }
        }
    }
    
    func _deleteObjects(byIds objectIds: [String], from tableName: String) {
        guard MementoKV._checkTableName(tableName), let dbQueue = dbQueue, !objectIds.isEmpty else { return }
        let idsString = objectIds.map { "'\($0)'" }.joined(separator: ",")
        let sql = String(format: MementoKV.DELETE_ITEMS_SQL, tableName, idsString)
        dbQueue.inDatabase { db in
            do { try db.executeUpdate(sql, values: []) }
            catch { print("ERROR: Failed to delete items by ids from '\(tableName)': \(error)") }
        }
    }
    
    func _deleteObjects(byPrefix prefix: String, from tableName: String) {
        guard MementoKV._checkTableName(tableName), let dbQueue = dbQueue else { return }
        let sql = String(format: MementoKV.DELETE_ITEMS_WITH_PREFIX_SQL, tableName)
        let prefixArg = "\(prefix)%"
        dbQueue.inDatabase { db in
            do { try db.executeUpdate(sql, values: [prefixArg]) }
            catch { print("ERROR: Failed to delete items by prefix from '\(tableName)': \(error)") }
        }
    }
    
    // MARK: - Close
    func _close() { dbQueue?.close(); dbQueue = nil }
}

