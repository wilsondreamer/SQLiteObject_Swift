//
//  Person.swift
//  SQLiteObject_Example
//
//  Created by wilson on 2019/6/23.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SQLiteObject

//暂时支持属性是Int,String,Float,Double类型,其他类型不支持
class Person: SQLiteObject {
    
    enum GenderType : Int {
        case male
        case female
        case neutral
    }
    
    var firstName = ""
    var lastName = ""
    var age = 0
    var gender:GenderType = .male
    var email = ""
    
    //自定义表名称，如果不重实现改方法，改类的类名会是表名称
    override class func tableName() ->String {
        return "PersonInfo"
    }
    
    //是否转为sql命名规范
    override class func shouldConvertSQLColumn() ->Bool {
        return false
    }
}
