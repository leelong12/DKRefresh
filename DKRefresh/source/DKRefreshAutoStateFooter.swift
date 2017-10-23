//
//  DKRefreshAutoStateFooter.swift
//  DKRefresh
//
//  Created by lee on 2017/7/19.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit

open class DKRefreshAutoStateFooter: DKRefreshAutoFooter {
    
    /** 文字距离圈圈、箭头的距离 */
    open var labelLeftInset = DKRefreshLabelLeftInset
    /** 显示刷新状态的label */
    lazy open var stateLabel:UILabel =  {
        let label = UILabel.dk_label()
        self.addSubview(label)
        return label
    }()
    
    var stateTitles :Dictionary<DKRefreshState,String> = Dictionary()
    
    /** 设置state状态下的文字 */
    open func set(title:String,state:DKRefreshState) -> Void {
        self.stateTitles[state] = title
        self.stateLabel.text = self.stateTitles[self.state]
    }
    
    //MARK - 私有方法
    @objc private func stateLabelClick() -> Void {
        if self.state == .idle {
            self.beginRefreshing()
        }
    }
    
    /** 隐藏刷新状态的文字 */
    open var isRefreshingTitleHidden = false
    
    override open func prepare() {
        super.prepare()
        // 初始化文字
        self.set(title: Bundle.dk_localized(DKRefreshAutoFooterIdleText), state: .idle)
        self.set(title: Bundle.dk_localized(DKRefreshAutoFooterRefreshingText), state: .refreshing)
        self.set(title: Bundle.dk_localized(DKRefreshAutoFooterNoMoreDataText), state: .noMoreData)
        
        // 监听label
        self.stateLabel.isUserInteractionEnabled = true
        self.stateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stateLabelClick)))
    }
    
    override open func placeSubviews() {
        super.placeSubviews()
        if (self.stateLabel.constraints.count > 0) {return}
        
        // 状态标签
        self.stateLabel.frame = self.bounds
    }
    
    override open var state: DKRefreshState{
        didSet{
            if (self.isRefreshingTitleHidden && state == .refreshing) {
                self.stateLabel.text = nil
            } else {
                self.stateLabel.text = self.stateTitles[state]
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
