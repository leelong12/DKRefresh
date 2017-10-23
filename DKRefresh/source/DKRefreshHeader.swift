//
//  DKRefreshHeader.swift
//  DKRefresh
//
//  Created by lee on 2017/6/21.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit

open class DKRefreshHeader: DKRefreshComponent {

    /** 创建header */
    class open func header(refreshingBlock:@escaping DKRefreshComponentRefreshingBlock)->DKRefreshHeader{
        let header = self.init()
        header.refreshingBlock = refreshingBlock
        return header
    }
    /** 创建header */
    class open func header(target:AnyObject,action:Selector)->DKRefreshHeader{
        let header = self.init()
        header.refreshing(target: target, refreshingAction: action)
        return header
    }
    
    /** 这个key用来存储上一次下拉刷新成功的时间 */
    var lastUpdatedTimeKey :String = DKRefreshHeaderLastUpdatedTimeKey
    /** 上一次下拉刷新成功的时间 */
    open var lastUpdatedTime :Date?{
        get{
            return UserDefaults.standard.object(forKey: self.lastUpdatedTimeKey) as? Date
        }
    }
    /// 忽略多少scrollView的contentInset的top
    open var ignoredScrollViewContentInsetTop :CGFloat = 0.0
    
    var insetTDelta :CGFloat?
    
    //MARK - 覆盖父类的方法
    
    override open func prepare() {
        super.prepare()
        // 设置key
        self.lastUpdatedTimeKey = DKRefreshHeaderLastUpdatedTimeKey;
        
        // 设置高度
        self.dk_h = DKRefreshHeaderHeight;
    }
    
    override open func placeSubviews() {
        super.placeSubviews()
        // 设置y值(当自己的高度发生改变了，肯定要重新调整Y值，所以放到placeSubviews方法中设置y值)
        self.dk_y = -self.dk_h - self.ignoredScrollViewContentInsetTop;
    }
    
    override open func scrollViewContentOffsetDidChange(_ change: Dictionary<NSKeyValueChangeKey, Any>?) {
        super.scrollViewContentOffsetDidChange(change)
        
        // 在刷新的refreshing状态
        if (self.state == .refreshing) {
            if (self.window == nil) {return}
            // sectionheader停留解决
            var insetT = -self.scrollView!.dk_offsetY > self.scrollViewOriginalInset.top ? -self.scrollView!.dk_offsetY : self.scrollViewOriginalInset.top
            insetT = insetT > self.dk_h + self.scrollViewOriginalInset.top ? self.dk_h + self.scrollViewOriginalInset.top : insetT
            self.scrollView?.dk_insetT = insetT
            
            self.insetTDelta = self.scrollViewOriginalInset.top - insetT
            return
        }
        // 跳转到下一个控制器时，contentInset可能会变
        self.scrollViewOriginalInset = self.scrollView!.dk_inset;
        // 当前的contentOffset
        let offsetY = self.scrollView!.dk_offsetY
        // 头部控件刚好出现的offsetY
        let happenOffsetY = -self.scrollViewOriginalInset.top
        // 如果是向上滚动到看不见头部控件，直接返回
        // >= -> >
        if (offsetY > happenOffsetY) {return}
        
        // 普通 和 即将刷新 的临界点
        let normal2pullingOffsetY = happenOffsetY - self.dk_h;
        let pullingPercent = (happenOffsetY - offsetY) / self.dk_h;
        
        if (self.scrollView!.isDragging) { // 如果正在拖拽
            self.pullingPercent = pullingPercent
            if (self.state == .idle && offsetY < normal2pullingOffsetY) {
                // 转为即将刷新状态
                self.state = .pulling
            } else if (self.state == .pulling && offsetY >= normal2pullingOffsetY) {
                // 转为普通状态
                self.state = .idle
            }
        } else if (self.state == .pulling) {// 即将刷新 && 手松开
            // 开始刷新
            beginRefreshing()
        } else if (pullingPercent < 1) {
            self.pullingPercent = pullingPercent
        }
    }
    
    open override var state: DKRefreshState {
        get{
            return super.state
        }
        set{
            let oldState = super.state
            super.state = newValue
            // 根据状态做事情
            if (newValue == .idle) {
                if (oldState != .refreshing) {return}
                
                // 保存刷新时间
                UserDefaults.standard.set(Date(), forKey: self.lastUpdatedTimeKey)
                UserDefaults.standard.synchronize()
                
                // 恢复inset和offset
                UIView.animate(withDuration: DKRefreshSlowAnimationDuration, animations: { 
                    self.scrollView!.dk_insetT += self.insetTDelta!;
                    
                    // 自动调整透明度
                    if (self.isAutomaticallyChangeAlpha) {self.alpha = 0.0}
                }, completion: { (finished) in
                    self.pullingPercent = 0.0;
                    
                    if (self.endRefreshingCompletionBlock != nil) {
                        self.endRefreshingCompletionBlock!();
                    }
                })
            } else if (newValue == .refreshing) {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: DKRefreshFastAnimationDuration, animations: { 
                        let top = self.scrollViewOriginalInset.top + self.dk_h;
                        // 增加滚动区域top
                        self.scrollView!.dk_insetT = top;
                        // 设置滚动位置
                        self.scrollView?.setContentOffset(CGPoint(x:0,y:-top), animated: false)
                    }, completion: { (finished) in
                        self.executeRefreshingCallback()
                    })
                }
            }
        }
    }
    
    public override func endRefreshing(_ completionBlock: DKRefreshComponentbeginRefreshingCompletionBlock?) {
        self.endRefreshingCompletionBlock = completionBlock
        DispatchQueue.main.async {
            self.state = .idle
        }
    }
}
