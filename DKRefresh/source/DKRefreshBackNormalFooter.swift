//
//  DKRefreshBackNormalFooter.swift
//  DKRefresh
//
//  Created by lee on 2017/7/18.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit

open class DKRefreshBackNormalFooter: DKRefreshBackStateFooter {

    var arrowView: UIImageView = UIImageView(image: Bundle.dk_arrowImage())
    
    /** 菊花的样式 */
    var activityIndicatorViewStyle :UIActivityIndicatorViewStyle = .gray{
        didSet{
            self.loadingView?.removeFromSuperview()
            self.loadingView = nil
            setNeedsLayout()
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
            arrowCenterX -= self.labelLeftInset + self.stateLabel.dk_textWith() * 0.5
        }
        let arrowCenterY = self.dk_h * 0.5;
        let arrowCenter = CGPoint(x:arrowCenterX, y:arrowCenterY)
        
        // 箭头
        if (self.arrowView.constraints.count == 0) {
            self.arrowView.dk_size = self.arrowView.image?.size ?? CGSize.zero
            self.arrowView.center = arrowCenter
        }
        
        // 圈圈
        if (self.checkLoadingView().constraints.count == 0) {
            self.checkLoadingView().center = arrowCenter;
        }
        
        self.arrowView.tintColor = self.stateLabel.textColor
    }
    
    override open var state: DKRefreshState{
        didSet{
            // 根据状态做事情
            if (state == .idle) {
                if (oldValue == .refreshing) {
                    self.arrowView.transform = CGAffineTransform.init(rotationAngle: CGFloat(0.000001 - .pi))
                    UIView.animate(withDuration: DKRefreshSlowAnimationDuration, animations: { 
                        self.checkLoadingView().alpha = 0.0
                    }, completion: { (finished) in
                        self.checkLoadingView().alpha = 1.0
                        self.checkLoadingView().stopAnimating()
                        
                        self.arrowView.isHidden = false
                    })
                } else {
                    self.arrowView.isHidden = false
                    self.checkLoadingView().stopAnimating()
                    UIView.animate(withDuration: DKRefreshFastAnimationDuration, animations: { 
                        self.arrowView.transform = CGAffineTransform.init(rotationAngle: CGFloat(0.000001 - .pi))
                    })
                }
            } else if (state == .pulling) {
                self.arrowView.isHidden = false
                self.checkLoadingView().stopAnimating()
                UIView.animate(withDuration: DKRefreshFastAnimationDuration, animations: {
                    self.arrowView.transform = CGAffineTransform.identity
                })
            } else if (state == .refreshing) {
                self.arrowView.isHidden = true
                self.checkLoadingView().startAnimating()
            } else if (state == .noMoreData) {
                self.arrowView.isHidden = false
                self.checkLoadingView().stopAnimating()
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
