//
//  Reflection.swift
//  SwiftFramework
//
//  Created by wilson on 2019/6/13.
//  Copyright © 2019 wilson. All rights reserved.
//

import UIKit

public class ReflectionProperty {
    
    var type:Any.Type?
    var key:String?
    var value:Any?
    
    public init() {

    }
    
    fileprivate init(anyObject:Any) {

        let mirror = Mirror(reflecting: anyObject)
        self.type = mirror.subjectType
        
        for childen in mirror.children {
            self.key = childen.label
            self.value = childen.value
        }
        self.value = anyObject
    }
}

public class Reflection: NSObject {

    var properties:[ReflectionProperty] = []
    var style:Mirror.DisplayStyle?
    
    @available(*,unavailable)
    override init() {
        
    }
    
    init(object:Any) {
        super.init()
        let mirror:Mirror = Mirror(reflecting: object)
        self.style = mirror.displayStyle
        
        if let superClass = mirror.superclassMirror {
            
            for children in superClass.children {
                
                let property =  ReflectionProperty(anyObject: children.value)
                property.key = children.label
                self.properties.append(property)
            }
        }
        
        for children in mirror.children {
            
            let property =  ReflectionProperty(anyObject: children.value)
            property.key = children.label
            self.properties.append(property)
        }
    }
    
    init(anyClass:AnyClass) {
        super.init()
        print(anyClass)
        
//        let names = anyClass.get_class_copyPropertyList()
//        print(names)
//        let propertyNames = get_class_copyPropertyList(anyClass: anyClass)
//        for name in propertyNames {
//
//            let property = ReflectionProperty()
//            property.key = name
//            self.properties.append(property)
//        }
    }
    
//    func get_class_copyPropertyList(anyClass:AnyClass)->[String]{
//        var outCount:UInt32 = 0
//        let propers:UnsafeMutablePointer<objc_property_t>! =  class_copyPropertyList(NSClassFromString("Person"), &outCount)
//        let count:Int = Int(outCount);
//        var names:[String] = [String]()
//        for i in 0...(count-1) {
//            let aPro: objc_property_t = propers[i]
//            if let proName:String = String(utf8String: property_getName(aPro)){
//                names.append(proName)
//            }
//        }
//        return names
//    }
}


