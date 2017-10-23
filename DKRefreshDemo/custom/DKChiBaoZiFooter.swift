//
//  DKChiBaoZiFooter.swift
//  DKRefreshDemo
//
//  Created by lee on 2017/10/19.
//  Copyright © 2017年 lee. All rights reserved.
//

import Foundation
import DKRefresh

class DKChiBaoZiFooter: DKRefreshAutoGifFooter {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
//    #pragma mark - 重写方法
//    #pragma mark 基本设置
    override func prepare() {
        super.prepare()
        var refreshingImages:Array<UIImage> = Array()
        for index in 1...3 {
            let image = UIImage(named: "dropdown_loading_0\(index)")
            refreshingImages.append(image!)
        }
        set(images: refreshingImages, state: .refreshing)
    }
}
