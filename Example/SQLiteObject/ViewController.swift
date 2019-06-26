//
//  ViewController.swift
//  SQLiteObject
//
//  Created by wilson on 06/23/2019.
//  Copyright (c) 2019 wilson. All rights reserved.
//

import UIKit
import SQLiteObject

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //创建数据库
        print("------------连接数据库-----------------")
        self.createDatabase()
        
        //插入数据
        print("-------------插入数据-----------------")
        self.insertData()
        
        //查询数据
        print("-------------查询数据-----------------")
        self.queryData()
    }
    
    /// 创建数据库
    func createDatabase()  {
        
        let path = NSTemporaryDirectory()
        let dataBasePath = String("\(path)demo.sqlite")
        
        SQLiteManager.shareManager.debugEnable = true
        let result = SQLiteManager.shareManager.connectTo(filePath: dataBasePath);
        if result == true {
            print("连接数据库成功")
        }
    }
    
    func insertData()  {
        
        let person:Person = Person()
        person.firstName = "wilson"
        person.lastName = "lin"
        person.age = 28
        person.gender = .male
        person.email = "wsn7156@gmail.con"
        let result = person.save()
        if result == true {
            print("插入数据成功")
        }else {
            print("插入数据失败")
        }
    }
    func queryData() {
        
        let persons = Person.findBy(dict: ["firstName":"wilson"])
        for person  in persons {
            
            let cPerson = person as! Person
            print("姓名:\(cPerson.lastName)\(cPerson.firstName)")
        }
    }
}


