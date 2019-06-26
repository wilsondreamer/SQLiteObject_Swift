//
//  SQLiteObject.swift
//  SwiftFramework
//
//  Created by wilson on 2019/6/15.
//  Copyright © 2019 wilson. All rights reserved.
//

import UIKit
import SQLite

enum SqliteSortType {
    case none
    case asc
    case desc
}

@objcMembers open class SQLiteObject:NSObject {
    
    var pk:Int64 = -1
    
    required public override init() {
        
    }
    
    /// 用sql语句查询数据,只能查出该表，表名需要与该类型一致
    ///
    /// - Parameter sql: sql语句 查询的表只能改类定义的表名称
    /// - Returns: 返回对象数组
    public class func findBy(sql:String) -> [SQLiteObject]? {
        
        do {
            let statement = try SQLiteManager.shareManager.connect?.prepare(sql)
            if let result = statement {
                
                SQLiteManager.shareManager.log("查询数据:\(result)")
                let columnsName = result.columnNames;
                let ns = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                let className = String(describing: self)
                let cls:AnyClass? = NSClassFromString(ns + "." + className)
                
                if let c = cls {
                 
                    let cType = c as! SQLiteObject.Type
                    var datas = [SQLiteObject]();
                    for data in result {
                        
                        let object = cType.init()
                        for (index,key) in columnsName.enumerated() {
                            
                            if let value = data[index] {
                                object.setValue(value, forKey: key)
                            }
                        }
                        datas.append(object)
                    }
                    return datas.count > 0 ? datas:nil
                }
            }
           
        }catch {
            SQLiteManager.shareManager.log("查询数据表:\(self.fetchTableName())失败")
            return nil
        }
        return nil
    }
    
    
    /// 根据自增长id查询
    ///
    /// - Parameter pk: 默认创建的自增长id
    /// - Returns: 返回对象数组
    public class func findBy(pk:Int64) -> [SQLiteObject]? {
        
        let sql = "SELECT * FROM \(self.fetchTableName()) WHERE pk = \(pk)";
        let objects = self.findBy(sql: sql)
        return objects
    }
    
    
    /// 保存数据
    ///
    /// - Returns: 返回是否成功
    public func save() ->Bool {
        
        let objectClass = type(of: self)
        let table = objectClass.createTable()
        if table != nil {
            return self.update()
        }
        return false
    }
    
    
    /// 删除数据
    ///
    /// - Returns: 返回是否成功
    public func delete() ->Bool {
        
        if self.pk >= 0 {
            
            let sql = "DELETE FROM \(type(of: self).fetchTableName()) WHERE pk = \(self.pk)"
            do {
                
                let statement = try SQLiteManager.shareManager.connect?.run(sql)
                if statement != nil {
                    
                    SQLiteManager.shareManager.log("删除数据成功:pk=\(self.pk)")
                    return true
                }
            }catch {
                SQLiteManager.shareManager.log("删除数据失败:\(error)")
                return false
            }
        }
        
        return false
    }
    
    
    /// 約束查詢
    ///
    /// - Parameters:
    ///   - dict: and字段
    ///   - orDict: or字段
    ///   - limit: limit字段
    ///   - orderBy: order by字段
    /// - Returns: 返回對象數組
    class func findBy(dict:Dictionary<String,Any>? = nil,orDict:Dictionary<String,Any>? = nil,limit:Int? = nil,orderBy:[String:SqliteSortType]? = nil) ->[SQLiteObject]? {
        
        let tableName = self.fetchTableName()
        var dictString = ""
        var orString = ""
        var orderString = ""
        var limitString = ""
        // and
        if let di = dict {
            
            let keys = [String](di.keys)
            for (index,key) in keys.enumerated() {
                
                let newKey = self.shouldConvertSQLColumn() ? key.stringAsSQLColumnName() : key
                dictString.append(newKey)
                dictString.append(" = ")
                
                let value = di[key]
                if let v = value {
                    if v is String {
                        dictString.append("'\(v)\'")
                    }else {
                        dictString.append("\(v)")
                    }
                }
                if index != keys.count - 1 {
                    dictString.append(" and ")
                }
            }
        }
        
        //or
        if let orDic = orDict {
            
            if dictString.isEmpty == false {
                orString.append(" OR ")
            }
            let keys = [String](orDic.keys)
            for (index,key) in keys.enumerated() {
                
                let newKey = self.shouldConvertSQLColumn() ? key.stringAsSQLColumnName() : key
                orString.append(newKey)
                orString.append(" = ")
                
                let value = orDic[key]
                if let v = value {
                    if v is String {
                        orString.append("'")
                        orString.append("\(v)")
                        orString.append("'")
                    }else {
                        orString.append("\(v)")
                    }
                }
                if index != keys.count - 1 {
                    orString.append(" OR ")
                }
            }
        }
        
        //order by
        if let orderDic = orderBy {
            
            orderString = " ORDER BY "
            
            let keys = [String](orderDic.keys)
            for (index,key) in keys.enumerated() {
                
                let newKey = self.shouldConvertSQLColumn() ? key.stringAsSQLColumnName() : key
                let type = orderDic[key]
                
                orderString.append(newKey)
                if type == SqliteSortType.asc {
                    orderString.append(" ASC")
                }else if type == SqliteSortType.desc {
                    orderString.append(" DESC")
                }
                
                if index != keys.count - 1 {
                    orderString.append(" , ")
                }
            }
        }
        
        if let li = limit {
            limitString = "LIMIT \(li)"
        }
        
        var sql = "SELECT * FROM \(tableName)"
        if dictString.isEmpty == false {
            sql.append(" WHERE")
            sql.append(" \(dictString)")
        }
        
        if orString.isEmpty == false {
            sql.append("\(orString)")
        }
        
        if orderString.isEmpty == false {
            sql.append(orderString)
        }
        
        if limitString.isEmpty == false {
            sql.append(" \(limitString)")
        }
        
        let newSql = sql.replacingOccurrences(of: "\\", with: "")
        return self.findBy(sql: newSql) ?? []
    }
    
    public class func findBy(dict:Dictionary<String, Any>) ->[SQLiteObject] {
        return self.findBy(dict: dict, orDict: nil, limit: nil, orderBy: nil) ?? []
    }
    
    public class func findBy(orDict:Dictionary<String, Any>) ->[SQLiteObject] {
        return self.findBy(dict: nil, orDict: orDict, limit: nil, orderBy: nil) ?? []
    }
    
    public class func findBy(dict:Dictionary<String, Any>, orDict:Dictionary<String, Any>) ->[SQLiteObject] {
        return findBy(dict: dict, orDict: orDict, limit: nil, orderBy: nil) ?? []
    }
    
    /// 刪除該表
    public class func dropTable() {
        
        let tableName = self.fetchTableName()
        let sql = "DROP TABLE \(tableName)"
        do {
            try SQLiteManager.shareManager.connect?.run(sql)
        }catch {
            SQLiteManager.shareManager.log("刪除數據表:\(error)")
        }
    }
 
    //自定義表名
    open class func tableName() ->String {
        return ""
    }
    
    //是否把字段轉為數據庫字段格式,如果已经有数据的话会自动创建新的
    open class func shouldConvertSQLColumn() ->Bool {
        return false
    }
}


fileprivate extension SQLiteObject {
    
    class func fetchTableName() ->String {
        
        let tableName = String(describing: self)
        let customTableName = self.tableName()
        if customTableName.count > 0 {
            return customTableName
        }
        return tableName
    }
    
    //創建表
    class func createTable() -> Table?{
        
        let tableName = self.fetchTableName()
        let table = Table(tableName)
        
        do {
            
            //检查是否有该数据表
            if self.existTableName(tableName: tableName) {
                
                let properties = self.getPropertyList()
                if let oldColumnNames = try SQLiteManager.shareManager.connect?.prepare(table.expression.template, table.expression.bindings).columnNames {
                    
                    for property in properties {
                        
                        var isExist = false
                        let label = self.shouldConvertSQLColumn() ? property.sqlLabel : property.label
                        for columnName in oldColumnNames {
                            if columnName == label {
                                isExist = true;
                                break;
                            }
                        }
                        
                        if isExist == false {
                         
                            let result = self.addProperty(property: property, table: table)
                            SQLiteManager.shareManager.log("添加属性:\(label!):\(result == true ? "成功" : "失败")")
                        }
                    }
                }
            }else {
                
                //不存在则创建
                try SQLiteManager.shareManager.connect?.run(table.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (builder) in
                    
                    //創建主鍵
                    builder.column(Expression<Int64>("pk"), primaryKey: .autoincrement)
                    
                    //添加屬性
                    let properties = self.getPropertyList()
                    for property in properties {
                        
                        let result = self.appendProperty(property: property, tableBuilder: builder)
                        if result == true {
                            SQLiteManager.shareManager.log("添加數據庫字段成功...\(property.label!)")
                        }else {
                            SQLiteManager.shareManager.log("添加數據庫字段失敗...\(String(describing: property.type))")
                        }
                    }
                }))
            }
        }catch {
            SQLiteManager.shareManager.log("添加數據庫字段失敗:\(error)")
        }
        
        return table
    }
    
    class func existTableName(tableName:String?) ->Bool {
        
        if let t = tableName {
            
            do {
                
                let isExists = try SQLiteManager.shareManager.connect?.scalar(
                    "SELECT EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = ?)", t
                    ) as! Int64 > 0
                return isExists
            }catch {
                SQLiteManager.shareManager.log("检查表是否存在错误:\(error)")
                return false
            }
        }
        return false
    }

    class func appendProperty(property:SQLiteProperty,tableBuilder:TableBuilder) ->Bool {
        
        let shouldSql = self.shouldConvertSQLColumn()
        let sqlLabel = shouldSql ? property.sqlLabel : property.label
        
        if let label = sqlLabel {
            
            if let propertyType = property.type {
                
                let type = String(describing: propertyType).components(separatedBy: ".").first
                if let oType = type {
                    if oType == "Int" {
                        
                        tableBuilder.column(Expression<Int>(label))
                    }else if oType == "Int64" {
                        
                        tableBuilder.column(Expression<Int64>(label))
                    }else if oType == "String" || oType == "NSString" {
                        
                        tableBuilder.column(Expression<String>(label))
                    }else if oType == "Double" || oType == "Float" {
                        
                        tableBuilder.column(Expression<Double>(label))
                    }else {
                        
                        return false
                    }
                }
            }
            return true
        }
        return false
    }
    
    //已有数据表的添加属性
    class func addProperty(property:SQLiteProperty,table:Table) ->Bool {
        
        let shouldSql = self.shouldConvertSQLColumn()
        let sqlLabel = shouldSql ? property.sqlLabel : property.label
        
        if let label = sqlLabel {
            
            if let propertyType = property.type {
                
                var result = ""
                let type = String(describing: propertyType).components(separatedBy: ".").first
                if let oType = type {
                    
                    if oType == "Int" {
                        
                        result = table.addColumn(Expression<Int?>(label))
                    }else if oType == "Int64" {
                        
                        result = table.addColumn(Expression<Int64?>(label))
                    }else if oType == "String" || oType == "NSString" {
                        
                       result = table.addColumn(Expression<String?>(label))
                    }else if oType == "Double" || oType == "Float" {
                        
                       result = table.addColumn(Expression<Double?>(label))
                    }else {
                        
                        return false
                    }
                }
                if result.isEmpty == false {
                    do {
                        try SQLiteManager.shareManager.connect?.run(result)
                    }catch {
                        SQLiteManager.shareManager.log("插入属性失败:\(error)")
                    }
                }
            }
            return true
        }
        return false
    }
    
    //更新或插入数据
    func update() ->Bool {
        
        let objects = type(of: self).findBy(pk: self.pk)
        if objects != nil {
            
            //更新
            let sql = self.fetchObjectPropetySql(isInsert: false)
            let updateSql = "UPDATE \(type(of: self).fetchTableName()) \(sql.replacingOccurrences(of: "\\", with: ""))"
            
            do {
                
                let statement = try SQLiteManager.shareManager.connect?.run(updateSql)
                if statement != nil {
                    
                    SQLiteManager.shareManager.log("成功更新数据,表名称:\(type(of: self).fetchTableName())")
                    return true
                }
            }catch {
                
                SQLiteManager.shareManager.log("更新数据失败,表名称:\(type(of: self).fetchTableName()),error:\(error)")
                return false
            }
            
        }else {
            
            //插入数据
            let sql = self.fetchObjectPropetySql(isInsert: true)
            let insertSql = "INSERT INTO \(type(of: self).fetchTableName()) \(sql)"
            do {
                
                let statement = try SQLiteManager.shareManager.connect?.run(insertSql)
                if statement != nil {
                    SQLiteManager.shareManager.log("成功插入数据,表名称:\(type(of: self).fetchTableName())")
                    return true
                }
            }catch {
                SQLiteManager.shareManager.log("插入数据失败,表名称:\(type(of: self).fetchTableName()),error:\(error)")
                return false
            }
        }
        return false
    }
    
    func fetchObjectPropetySql(isInsert:Bool) -> String {
        
        let reflect = Reflection(object: self)
        var sql = ""
        
        do {
            
            let querySql = "SELECT * FROM \(type(of: self).fetchTableName())"
            let columns = try SQLiteManager.shareManager.connect?.run(querySql).columnNames
            
            //插入格式
            var keyString = ""
            var valueString = ""
            
            //更新格式
            var updateString = ""
            
            for (index,property) in reflect.properties.enumerated() {
                
                //如果数据库字段没有匹配的，则不更新
                guard columns?.contains(property.key!) != false else {
                    continue
                }
                
                if let value = property.value {
                    
                    if isInsert == true {
                        
                        //插入数据格式
                        if keyString.count > 0 && valueString.count > 0 {
                            keyString.append(",")
                            valueString.append(",")
                        }
                        
                        guard property.key! != "pk" else {
                            continue
                        }
                        
                        keyString.append("\(property.key!)")
                        if property.value is String || property.value is NSString {
                            
                            valueString.append("\"\(value)\"")
                        }else {
                            valueString.append("\(value)")
                        }
                    }
                    if index == reflect.properties.count - 1 {
                        
                    }else {
                        
                        //更新数据
                        guard property.key != "pk" else {
                            pk = value as! Int64
                            continue
                        }
                        
                        if property.value is String || property.value is NSString {
                            
                            let newValue = "\"\(value)\""
                            updateString.append("\(property.key!) = \(newValue)")
                        }else {
                            
                            updateString.append("\(property.key!) = \(value)")
                        }
                        
                        if index != reflect.properties.count - 1 {
                            updateString.append(",")
                        }
                    }
                }
            }

            if isInsert == true {
                sql = "(\(keyString)) VALUES (\(valueString))"
            }else {
                let newString = updateString.replacingOccurrences(of: "\\", with: "")
                sql = "SET \(newString) WHERE pk = \(pk)".replacingOccurrences(of: "\\", with: "")
            }
        }catch {
            
            SQLiteManager.shareManager.log("更新数据失败:\(error)")
        }
        return sql
    }
    
    func checkChangePropety() {
        
//        guard isCachePropetySql() != type(of: self).shouldConvertSQLColumn() else {
//            return
//        }
        
        //查出表字段名称
        do {
            
            let tableName = type(of: self).fetchTableName()
            let sql = "SELECT * FROM \(tableName) limit 1"
            let statememt = try SQLiteManager.shareManager.connect?.run(sql)
            
            let properties = type(of: self).getPropertyList()
            if let columNames = statememt?.columnNames {
                
                for property in properties {
                    
                    let key = type(of: self).shouldConvertSQLColumn() ? property.label! : property.sqlLabel!
                    let result = columNames.filter { (string) -> Bool in
                       return  string == key
                    }.first
                    if let res = result {
                        
                        let key = type(of: self).shouldConvertSQLColumn() ? property.sqlLabel! : property.label!
                        let sql = "ALTER TABLE \"\(tableName)\" RENAME COLUMN \"\(res)\" TO \"\(key)\""
                        print("SQL:\(sql)")
                        do {
                            let statment = try SQLiteManager.shareManager.connect?.run(sql)
                            if statment != nil {
                                SQLiteManager.shareManager.log("修改数据表:\(tableName)字段成功:\(res)")
                            }
                        }catch {
                            SQLiteManager.shareManager.log("修改数据表:\(tableName)字段失败:\(res)")
                        }
                    }
                }
            }
        }catch {
            SQLiteManager.shareManager.log("\(error)")
        }
    }
    
    func isCachePropetySql() -> Bool {
        
        let value = type(of: self).shouldConvertSQLColumn()
        let tableName = type(of: self).fetchTableName()
        let sqlitekey = "SQLITE_SAVE_KEY"
        let userInfo = UserDefaults.standard
        if let dictionary = userInfo.object(forKey: sqlitekey) {
            
            var dic = dictionary as! [String:Bool]
            if let v = dic[tableName] {
                
                dic[tableName] = value
                return v
            }else {
                
                dic[tableName] = value
            }
            userInfo.set(dic, forKey: sqlitekey)
            userInfo.synchronize()
            return value
            
        }else {
           
            var dict = [String:Bool]()
            dict[tableName] = value
            userInfo.set(dict, forKey: sqlitekey)
            userInfo.synchronize()
        }
        return value
    }
}

class SQLiteProperty {
    
    private(set) var sqlLabel:String?
    private(set) var label:String?
    private(set) var value:Any?
    private(set) var type:Any.Type?
    
    init(object:ReflectionProperty) {

        self.label = object.key
        self.value = object.value
        self.sqlLabel = object.key?.stringAsSQLColumnName()
        self.type = object.type
    }
    
    init(property:objc_property_t,name:String?) {
        
        self.label = name;
        self.sqlLabel = name?.stringAsSQLColumnName()
        
        let valueType = self.getTypeOf(property: property)
        
        if valueType == "Int"  {
            self.type = Int64.Type.self
        }else if valueType == "Int8" {
            self.type = Int8.Type.self
        }else if valueType == "Int16" {
            self.type = Int16.Type.self
        }else if valueType == "Int32" {
            self.type = Int32.Type.self
        }else if valueType == "Bool" {
            self.type = Bool.Type.self
        }else if valueType == "Double" || valueType == "Float" {
            self.type = Double.Type.self
        }else if valueType == "String" || valueType == "NSString" {
            self.type = String.Type.self
        }
    }
    
    func getTypeOf(property: objc_property_t) -> String? {
        
        guard let attributesAsNSString: NSString = NSString(utf8String: property_getAttributes(property)!) else { return nil }
        let attributes = attributesAsNSString as String
        let slices = attributes.components(separatedBy: "\"")
        guard slices.count > 1 else { return valueType(withAttributes: attributes) }
        let objectClassName = slices[1]
        return objectClassName
    }
    
    fileprivate func valueType(withAttributes attributes: String) -> String? {
        
        let valueTypesMap: Dictionary<String, String> = [
            "c" : "Int8",
            "s" : "Int16",
            "i" : "Int32",
            "q" : "Int", //also: Int64, NSInteger, only true on 64 bit platforms
            "S" : "UInt16",
            "I" : "UInt32",
            "Q" : "UInt", //also UInt64, only true on 64 bit platforms
            "B" : "Bool",
            "d" : "Double",
            "f" : "Float",
            "{" : "Decimal"
        ]
        
        let tmp = attributes as NSString
        let letter = tmp.substring(with: NSMakeRange(1, 1))
        guard let type = valueTypesMap[letter] else { return nil }
        return type
    }
}

extension String {
    
    func stringAsSQLColumnName() -> String {
        
        var name = String()
        for char in self {
            
            let str = String(char)
            if str == str.uppercased() {
                name.append("_\(str)")
            }else {
                name.append("\(str.lowercased())")
            }
        }
        return name
    }
}

extension NSObject{
    
    /// 获取类的属性列表
    ///
    /// - Returns:  属性名列表
    class func get_class_copyPropertyList()->[String]{
        var outCount:UInt32 = 0
        let propers:UnsafeMutablePointer<objc_property_t>! =  class_copyPropertyList(self, &outCount)
        let count:Int = Int(outCount);
        var names:[String] = [String]()
        for i in 0...(count-1) {
            let aPro: objc_property_t = propers[i]
            if let proName:String = String(utf8String: property_getName(aPro)){
                names.append(proName)
            }
        }
        return names
    }
    
    /// 获取类的方法列表
    ///
    /// - Returns: 方法名列表
    class func get_class_copyMethodList() -> [String]{
        var outCount:UInt32
        outCount = 0
        let methods:UnsafeMutablePointer<objc_property_t>! =  class_copyMethodList(self, &outCount)
        let count:Int = Int(outCount);
        var names:[String] = [String]()
        for i in 0...(count-1) {
            
            let aMet: objc_property_t = methods[i]
            
            if let methodName:String = String(utf8String: property_getName(aMet)){
                names.append(methodName)
            }
        }
        return names
    }
    
     class func getPropertyList() ->[SQLiteProperty] {
        
        var properties = [SQLiteProperty]()
        
        var outCount:UInt32 = 0
        let propers:UnsafeMutablePointer<objc_property_t>! =  class_copyPropertyList(self, &outCount)
        let count:Int = Int(outCount);
        for i in 0...(count-1) {
            let aPro: objc_property_t = propers[i]
            if let proName:String = String(utf8String: property_getName(aPro)){
                
                let property = SQLiteProperty(property: aPro, name: proName)
                properties.append(property)
            }
        }
        
        return properties
    }
}
