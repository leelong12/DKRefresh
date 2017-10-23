//
//  DKRefreshNormalHeader.swift
//  DKRefresh
//
//  Created by lee on 2017/7/7.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit

open class DKRefreshNormalHeader: DKRefreshStateHeader {

    lazy var arrowView: UIImageView = {
        let arrowView = UIImageView(image: Bundle.dk_arrowImage())
        return arrowView
    }()
    /** 菊花的样式 */
    public var activityIndicatorViewStyle:UIActivityIndicatorViewStyle = .gray{
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
        self.addSubview(arrowView)
    }
    
    override open func placeSubviews() {
        super.placeSubviews()
        // 箭头的中心点
        var arrowCenterX = self.dk_w * 0.5
        if (!self.stateLabel.isHidden) {
            let stateWidth = self.stateLabel.dk_textWith()
            var timeWidth: CGFloat = 0.0
            if (!self.lastUpdatedTimeLabel.isHidden) {
                timeWidth = self.lastUpdatedTimeLabel.dk_textWith()
            }
            let textWidth = max(stateWidth, timeWidth)
            arrowCenterX -= textWidth / 2 + self.labelLeftInset
        }
        let arrowCenterY = self.dk_h * 0.5
        let arrowCenter = CGPoint(x:arrowCenterX, y:arrowCenterY)
        
        // 箭头
        if (self.arrowView.constraints.count == 0) {
            self.arrowView.dk_size = self.arrowView.image?.size ?? CGSize.zero
            self.arrowView.center = arrowCenter;
        }
        
        // 圈圈
        if (self.checkLoadingView().constraints.count == 0) {
            self.checkLoadingView().center = arrowCenter;
        }
        
        self.arrowView.tintColor = self.stateLabel.textColor
    }
    
    open override var state: DKRefreshState{
        didSet{
            // 根据状态做事情
            if (state == .idle) {
                if (oldValue == .refreshing) {
                    self.arrowView.transform = CGAffineTransform.identity
                    
                    UIView.animate(withDuration: DKRefreshSlowAnimationDuration, animations: { 
                        self.loadingView?.alpha = 0.0
                    }, completion: { (finished) in
                        // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                        if (self.state != .idle) {return}
                        
                        self.loadingView?.alpha = 1.0
                        self.loadingView?.stopAnimating()
                        self.arrowView.isHidden = false
                    })
                } else {
                    self.loadingView?.stopAnimating()
                    self.arrowView.isHidden = false
                    UIView.animate(withDuration: DKRefreshFastAnimationDuration, animations: { 
                        self.arrowView.transform = CGAffineTransform.identity
                    })
                }
            } else if (state == .pulling) {
                self.loadingView?.stopAnimating()
                self.arrowView.isHidden = false
                UIView.animate(withDuration: DKRefreshFastAnimationDuration, animations: { 
                    self.arrowView.transform = CGAffineTransform.init(rotationAngle: CGFloat(0.000001 - .pi))
                })
            } else if (state == .refreshing) {
                self.loadingView?.alpha = 1.0  // 防止refreshing -> idle的动画完毕动作没有被执行
                self.loadingView?.startAnimating()
                self.arrowView.isHidden = true
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
