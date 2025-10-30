# MementoKV

A lightweight iOS local key-value storage library, built on **FMDB**, supporting storage of JSON objects, strings, numbers, and more. Provides CRUD operations and table management.

Features:

- Lightweight, no need for `Codable`
- Supports storing arbitrary JSON objects
- Supports batch deletion and prefix-based deletion
- Table operations: create, drop, clear, check existence
- Stores creation time for each item
- Thread-safe via FMDatabaseQueue



## Features

### Table Operations

- `createTable(named:)` - Create a table
- `isTableExists(_:)` - Check if a table exists
- `clearTable(_:)` - Clear all data in a table
- `dropTable(_:)` - Drop a table

### Put Methods

- `putObject(_:withId:into:)` - Store any JSON object
- `putString(_:withId:into:)` - Store a string
- `putNumber(_:withId:into:)` - Store a number

### Get Methods

- `getObject(byId:from:)` - Get any object
- `getMementoKVItem(byId:from:)` - Get full item (id, object, creation time)
- `getString(byId:from:)` - Get a string
- `getNumber(byId:from:)` - Get a number
- `getAllItems(from:)` - Get all items in a table
- `getCount(from:)` - Get the count of items in a table

### Delete Methods

- `deleteObject(byId:from:)` - Delete a single item
- `deleteObjects(byIds:from:)` - Batch delete
- `deleteObjects(byPrefix:from:)` - Delete items by prefix

### Close

- `close()` - Close the database connection



## Installation

### CocoaPods

```
pod 'MementoKV', :git => 'https://github.com/your-username/MementoKV.git'
```



## Usage Example

```
import MementoKV

// Initialize
let kv = MementoKV(withName: "myDatabase.sqlite")

// Create a table
kv.createTable(named: "alarm_table")

// Store data
kv.putString("Alarm content", withId: "alarm_1", into: "alarm_table")
kv.putNumber(10, withId: "alarm_count", into: "alarm_table")
kv.putObject(["time": "08:00", "repeat": true], withId: "alarm_detail", into: "alarm_table")

// Retrieve data
let str = kv.getString(byId: "alarm_1", from: "alarm_table")
let num = kv.getNumber(byId: "alarm_count", from: "alarm_table")
let obj = kv.getObject(byId: "alarm_detail", from: "alarm_table")

// Delete data
kv.deleteObject(byId: "alarm_1", from: "alarm_table")

// Get table item count
let count = kv.getCount(from: "alarm_table")

// Close database
kv.close()
```



## Notes

- The stored data must be JSON-serializable
- Database operations are thread-safe using **FMDatabaseQueue**
- Table names cannot contain spaces or be empty



## Contributing

Feel free to submit issues or pull requests. Fork the repo and submit your improvements or new features.
