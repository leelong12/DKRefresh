//
//  DKRefreshBackFooter.swift
//  DKRefresh
//
//  Created by lee on 2017/7/10.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit

open class DKRefreshBackFooter: DKRefreshFooter {
    var lastRefreshCount:Int = 0
    var lastBottomDelta:CGFloat = 0
    
    //MARK - 初始化
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.scrollViewContentSizeDidChange(nil)
    }
    
    //MARK- 实现父类的方法
    override open func scrollViewContentOffsetDidChange(_ change: Dictionary<NSKeyValueChangeKey, Any>?) {
        super.scrollViewContentOffsetDidChange(change)
        
        // 如果正在刷新，直接返回
        if (self.state == .refreshing) {return}
        
        scrollViewOriginalInset = self.scrollView!.dk_inset
        
        // 当前的contentOffset
        let currentOffsetY = self.scrollView!.dk_offsetY
        // 尾部控件刚好出现的offsetY
        let happenOffsetY = self.happenOffsetY()
        // 如果是向下滚动到看不见尾部控件，直接返回
        if (currentOffsetY <= happenOffsetY) {return}
        
        let pullingPercent:CGFloat = (currentOffsetY - happenOffsetY) / self.dk_h;
        
        // 如果已全部加载，仅设置pullingPercent，然后返回
        if (self.state == .noMoreData) {
            self.pullingPercent = pullingPercent
            return;
        }
        
        if (self.scrollView!.isDragging) {
            self.pullingPercent = pullingPercent
            // 普通 和 即将刷新 的临界点
            let normal2pullingOffsetY = happenOffsetY + self.dk_h
            
            if (self.state == .idle && currentOffsetY > normal2pullingOffsetY) {
                // 转为即将刷新状态
                self.state = .pulling
            } else if (self.state == .pulling && currentOffsetY <= normal2pullingOffsetY) {
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
    
    override open func scrollViewContentSizeDidChange(_ change: Dictionary<NSKeyValueChangeKey, Any>?) {
        super.scrollViewContentSizeDidChange(change)
        // 内容的高度
        let contentHeight = (self.scrollView?.dk_contentH ?? 0) + self.ignoredScrollViewContentInsetBottom
        // 表格的高度
        let scrollHeight = (self.scrollView?.dk_h ?? 0) - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom + self.ignoredScrollViewContentInsetBottom
        // 设置位置和尺寸
        self.dk_y = max(contentHeight, scrollHeight)
    }
    
    override open var state: DKRefreshState{
        didSet{
            // 根据状态来设置属性
            if (state == .noMoreData || state == .idle) {
                // 刷新完毕
                if (.refreshing == oldValue) {
                    
                    UIView.animate(withDuration: DKRefreshSlowAnimationDuration, animations: { 
                        self.scrollView!.dk_insetB -= self.lastBottomDelta
                        
                        // 自动调整透明度
                        if (self.isAutomaticallyChangeAlpha) {self.alpha = 0.0}
                    }, completion: { (finished) in
                        self.pullingPercent = 0.0;
                        
                        if (self.endRefreshingCompletionBlock != nil) {
                            self.endRefreshingCompletionBlock!()
                        }
                    })
                }
                
                let deltaH = self.heightForContentBreakView()
                // 刚刷新完毕
                if (.refreshing == oldValue && deltaH > 0 && self.scrollView!.dk_totalDataCount() != self.lastRefreshCount) {
                    self.scrollView!.dk_offsetY = self.scrollView!.dk_offsetY
                }
            } else if (state == .refreshing) {
                // 记录刷新前的数量
                self.lastRefreshCount = self.scrollView!.dk_totalDataCount()
                
                UIView.animate(withDuration: DKRefreshFastAnimationDuration, animations: { 
                    var bottom = self.dk_h + self.scrollViewOriginalInset.bottom;
                    let deltaH = self.heightForContentBreakView()
                    if (deltaH < 0) { // 如果内容高度小于view的高度
                        bottom -= deltaH
                    }
                    self.lastBottomDelta = bottom - self.scrollView!.dk_insetB
                    self.scrollView!.dk_insetB = bottom
                    self.scrollView!.dk_offsetY = self.happenOffsetY() + self.dk_h
                }, completion: { (finished) in
                    self.executeRefreshingCallback()
                })
            }
        }
    }
    
    override public func endRefreshing(_ completionBlock: DKRefreshComponentbeginRefreshingCompletionBlock?) {
        DispatchQueue.main.async {
            self.endRefreshingCompletionBlock = completionBlock
            self.state = .idle;
        }
    }
    
    override public func endRefreshingWithNoMoreData() {
        DispatchQueue.main.async {
            self.state = .noMoreData
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //mark - 私有方法
    //mark 获得scrollView的内容 超出 view 的高度
    func heightForContentBreakView() -> CGFloat {
        let h = self.scrollView!.frame.size.height - self.scrollViewOriginalInset.bottom - self.scrollViewOriginalInset.top
        return self.scrollView!.contentSize.height - h
    }
    
    //mark 刚好看到上拉刷新控件时的contentOffset.y
    
    func happenOffsetY() -> CGFloat {
        let deltaH = heightForContentBreakView()
        if (deltaH > 0) {
            return deltaH - self.scrollViewOriginalInset.top
        } else {
            return -self.scrollViewOriginalInset.top
        }
    }

}
