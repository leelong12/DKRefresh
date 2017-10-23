//
//  DKRefreshAutoNormalFooter.swift
//  DKRefresh
//
//  Created by lee on 2017/7/19.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit

open class DKRefreshAutoNormalFooter: DKRefreshAutoStateFooter {

//    var <#name#> = <#value#>
    
    /** 菊花的样式 */
    var activityIndicatorViewStyle :UIActivityIndicatorViewStyle = .gray{
        didSet{
            self.loadingView?.removeFromSuperview()
            self.loadingView = nil
            self.setNeedsLayout()
        }
    }
    
    private var loadingView :UIActivityIndicatorView?
    
    func checkLoadingView() -> UIActivityIndicatorView {
        if self.loadingView == nil {
            self.loadingView = UIActivityIndicatorView(activityIndicatorStyle: self.activityIndicatorViewStyle)
            self.loadingView?.hidesWhenStopped = true
            self.addSubview(self.loadingView!)
        }
        return self.loadingView!
    }
    
    override open func prepare() {
        super.prepare()
    }
    
    override open func placeSubviews() {
        super.placeSubviews()
        if (self.checkLoadingView().constraints.count>0) {return}
        
        // 圈圈
        var loadingCenterX = self.dk_w * 0.5
        if (!self.isRefreshingTitleHidden) {
            loadingCenterX -= self.stateLabel.dk_textWith() * CGFloat(0.5) + self.labelLeftInset
        }
        let loadingCenterY = self.dk_h * CGFloat(0.5)
        self.checkLoadingView().center = CGPoint(x:loadingCenterX, y:loadingCenterY)
    }
    
    override open var state: DKRefreshState{
        didSet{
            // 根据状态做事情
            if (state == .noMoreData || state == .idle) {
                self.checkLoadingView().stopAnimating()
            } else if (state == .refreshing) {
                self.checkLoadingView().startAnimating()
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
