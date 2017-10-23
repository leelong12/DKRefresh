//
//  DKRefreshAutoFooter.swift
//  DKRefresh
//
//  Created by lee on 2017/7/11.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit

open class DKRefreshAutoFooter: DKRefreshFooter {
    /** 是否自动刷新(默认为YES) */
    open var isAutomaticallyRefresh = true
    
    /** 当底部控件出现多少时就自动刷新(默认为1.0，也就是底部控件完全出现时，才会自动刷新) */
    open var triggerAutomaticallyRefreshPercent :CGFloat = 1.0
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {// 新的父控件
            if self.isHidden == false {
                self.scrollView!.dk_insetB += self.dk_h
            }
            // 设置位置
            self.dk_y = self.scrollView!.dk_contentH
        }else{// 被移除了
            if (self.isHidden == false) {
                self.scrollView?.dk_insetB -= self.dk_h
            }
        }
    }
    
    //mark - 实现父类的方法
    override open func prepare() {
        super.prepare()
    }
    
    override open func scrollViewContentSizeDidChange(_ change: Dictionary<NSKeyValueChangeKey, Any>?) {
        super.scrollViewContentSizeDidChange(change)
        // 设置位置
        self.dk_y = self.scrollView!.dk_contentH
    }
    
    override open func scrollViewContentOffsetDidChange(_ change: Dictionary<NSKeyValueChangeKey, Any>?) {
        super.scrollViewContentOffsetDidChange(change)
        if (self.state != .idle || !self.isAutomaticallyRefresh || self.dk_y == 0) {return}
        
        if (self.scrollView!.dk_insetT + self.scrollView!.dk_contentH > self.scrollView!.dk_h) { // 内容超过一个屏幕
            // 这里的_scrollView.mj_contentH替换掉self.mj_y更为合理
            if (self.scrollView!.dk_offsetY >= self.scrollView!.dk_contentH - self.scrollView!.dk_h + self.dk_h * self.triggerAutomaticallyRefreshPercent + self.scrollView!.dk_insetB - self.dk_h) {
                // 防止手松开时连续调用
                let old = change?[NSKeyValueChangeKey.oldKey] as! CGPoint
                let new = change?[NSKeyValueChangeKey.newKey] as! CGPoint
                if (new.y <= old.y) {return}
                
                // 当底部刷新控件完全出现时，才刷新
                self.beginRefreshing()
            }
        }
    }
    
    override open func scrollViewPanStateDidChange(_ change: Dictionary<NSKeyValueChangeKey, Any>?) {
        super.scrollViewPanStateDidChange(change)
        if (self.state != .idle) {return}
        
        if (self.scrollView!.panGestureRecognizer.state == .ended) {// 手松开
            if (self.scrollView!.dk_insetT + self.scrollView!.dk_contentH <= self.scrollView!.dk_h) {  // 不够一个屏幕
                if (self.scrollView!.dk_offsetY >= -self.scrollView!.dk_insetT) { // 向上拽
                    self.beginRefreshing()
                }
            } else { // 超出一个屏幕
                if (self.scrollView!.dk_offsetY >= self.scrollView!.dk_contentH + self.scrollView!.dk_insetB - self.scrollView!.dk_h) {
                    self.beginRefreshing()
                }
            }
        }
    }
    
    override open var state: DKRefreshState{
        didSet{
            if (state == .refreshing) {
                let delay = DispatchTime.now() + .milliseconds(500)
                DispatchQueue.main.asyncAfter(deadline: delay, execute: { 
                    self.executeRefreshingCallback()
                })
            } else if (state == .noMoreData || state == .idle) {
                if (.refreshing == oldValue) {
                    if (self.endRefreshingCompletionBlock != nil) {
                        self.endRefreshingCompletionBlock!()
                    }
                }
            }
        }
    }
    
    override open var isHidden: Bool{
        didSet{
            if (!oldValue && isHidden) {
                self.state = .idle
                
                self.scrollView!.dk_insetB -= self.dk_h
            } else if (oldValue && !isHidden) {
                self.scrollView!.dk_insetB += self.dk_h
                
                // 设置位置
                self.dk_y = self.scrollView!.dk_contentH
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
