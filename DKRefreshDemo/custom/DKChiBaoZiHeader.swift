//
//  DKChiBaoZiHeader.swift
//  DKRefreshDemo
//
//  Created by lee on 2017/10/18.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit
import DKRefresh

class DKChiBaoZiHeader: DKRefreshGifHeader {

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
        // 设置普通状态的动画图片
        var idleImages:Array<UIImage> = Array();
        for index in 1...60 {
            let image = UIImage(named: "dropdown_anim__000\(index)")
            idleImages.append(image!);
        }
        set(images: idleImages, state: .idle)
        
        // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
        var refreshingImages:Array<UIImage> = Array();
        for index in 1...3 {
            let image = UIImage(named: "dropdown_loading_0\(index)")
            refreshingImages.append(image!);
        }
        set(images: refreshingImages, state: .pulling)
        
        // 设置正在刷新状态的动画图片
        set(images: refreshingImages, state: .refreshing)
    }

}
