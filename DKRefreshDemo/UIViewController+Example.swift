//
//  UIViewController+Example.swift
//  DKRefreshDemo
//
//  Created by lee on 2017/10/18.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit

public extension UIViewController{
    // 改进写法【推荐】
    struct RuntimeKey {
        static let DKMethodKey = UnsafeRawPointer.init(bitPattern: "DKMethodKey".hashValue)
        /// ...其他Key声明
    }
    
    public var method:String?{
        get{
            return objc_getAssociatedObject(self, UIViewController.RuntimeKey.DKMethodKey!) as? String
        }
        set{
            if self.method != newValue {
                objc_setAssociatedObject(self, UIViewController.RuntimeKey.DKMethodKey!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
        }
    }
    
}
