//
//  DKRefreshAutoGifFooter.swift
//  DKRefresh
//
//  Created by lee on 2017/7/19.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit

open class DKRefreshAutoGifFooter: DKRefreshAutoStateFooter {

    var gifView = UIImageView()
    
    var stateImages :Dictionary<DKRefreshState,Array<UIImage>> = Dictionary()
    
    var stateDurations :Dictionary<DKRefreshState,TimeInterval> = Dictionary()
    
    /** 设置state状态下的动画图片images 动画持续时间duration*/
    
    open func set(images:Array<UIImage>,duration:TimeInterval? = nil ,state:DKRefreshState) -> Void {
        stateImages[state] = images
        stateDurations[state] = duration ?? Double(images.count) * 0.1
        if let image = images.first {
            if image.size.height > self.dk_h {
                self.dk_h = image.size.height
            }
        }
    }
    
    //MARK - 实现父类的方法
    
    override open func prepare() {
        super.prepare()
        // 初始化间距
        self.labelLeftInset = 20
        self.addSubview(gifView)
    }
    
    override open func placeSubviews() {
        super.placeSubviews()
        if (self.gifView.constraints.count>0) {return}
        
        self.gifView.frame = self.bounds
        if (self.isRefreshingTitleHidden) {
            self.gifView.contentMode = .center
        } else {
            self.gifView.contentMode = .right
            self.gifView.dk_w = self.dk_w * 0.5 - self.labelLeftInset - self.stateLabel.dk_textWith() * 0.5
        }
    }
    
    override open var state: DKRefreshState{
        didSet{
            // 根据状态做事情
            if (state == .refreshing) {
                if let images = self.stateImages[state] {
                    if (images.count == 0) {return}
                    self.gifView.isHidden = false
                    self.gifView.stopAnimating()
                    if (images.count == 1) { // 单张图片
                        self.gifView.image = images.last!
                    } else { // 多张图片
                        self.gifView.animationImages = images
                        self.gifView.animationDuration = self.stateDurations[state] ?? Double(images.count) * 0.1
                        self.gifView.startAnimating()
                    }
                }
            } else if (state == .noMoreData || state == .idle) {
                self.gifView.stopAnimating()
                self.gifView.isHidden = true
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
