//
//  SQLiteManager.swift
//  SwiftFramework
//
//  Created by wilson on 2019/6/15.
//  Copyright © 2019 wilson. All rights reserved.
//

import UIKit
import SQLite

open class SQLiteManager {

    //share instance
    public static let shareManager:SQLiteManager = SQLiteManager()
    
    //數據連接
    public var connect:Connection?
    
    //連接數據庫超時時間
    public var timeout:Double = 5
    
    //調試模式
    public var debugEnable:Bool = false
    
    public func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        if debugEnable {
            print(items, separator: separator, terminator: terminator)
        }
    }
    
    //連接數據庫
    public func connectTo(filePath:String?) -> Bool {
        
        do {
            
            guard let path = filePath else {
                
                self.connect = try Connection(.temporary)
                self.connect?.busyTimeout = self.timeout
                self.log("沒有輸入數據庫路徑，已創建臨時數據庫")
                return false
            }
            
            self.connect = try Connection(path)
            self.connect?.busyTimeout = self.timeout
            if self.connect != nil {
                self.log("连接数据库成功,数据库路径:\(path)")
            }
        }catch {
            self.log("連接數據庫錯誤...\(error)")
            return false
        }
        return true
    }
    
    /// 斷開
    public func diconnect() {
        self.connect?.interrupt()
    }
}
