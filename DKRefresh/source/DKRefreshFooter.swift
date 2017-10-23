//
//  DKRefreshFooter.swift
//  DKRefresh
//
//  Created by lee on 2017/6/22.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit

open class DKRefreshFooter: DKRefreshComponent {

    /** 创建footer */
    class public func footer(refreshingBlock:@escaping DKRefreshComponentRefreshingBlock)->DKRefreshFooter{
        let footer = self.init();
        footer.refreshingBlock = refreshingBlock
        return footer
    }
    /** 创建footer */
    class public func footer(target:AnyObject,action:Selector)->DKRefreshFooter{
        let footer = self.init();
        footer.refreshing(target: target, refreshingAction: action)
        return footer
    }
    
    /** 忽略多少scrollView的contentInset的bottom */
    public var ignoredScrollViewContentInsetBottom:CGFloat = 0.0
    
    /** 自动根据有无数据来显示和隐藏（有数据就显示，没有数据隐藏。默认是NO） */
    //var automaticallyHidden = false
    
    override open func prepare() {
        super.prepare()
        // 设置自己的高度
        self.dk_h = DKRefreshFooterHeight
        
        // 默认不会自动隐藏
        //self.automaticallyHidden = false
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
//        if (newSuperview != nil) {
//            // 监听scrollView数据的变化
//            if self.scrollView!.isKind(of: UITableView.self) || self.scrollView!.isKind(of: UICollectionView.self) {
//                self.scrollView!.dk_reloadDataBlock{ (totalDataCount) in
//                    if (self.isAutomaticallyHidden) {
//                        self.hidden = (totalDataCount == 0)
//                    }
//                }
//            }
//        }
    }
    
    public func endRefreshingWithNoMoreData() -> Void {
        self.state = .noMoreData
    }
    
    public func resetNoMoreData() -> Void {
        self.state = .idle
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
