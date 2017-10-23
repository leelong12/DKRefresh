//
//  DKRefreshBackStateFooter.swift
//  DKRefresh
//
//  Created by lee on 2017/7/11.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit

open class DKRefreshBackStateFooter: DKRefreshBackFooter {

    /** 文字距离圈圈、箭头的距离 */
    public var labelLeftInset :CGFloat = DKRefreshLabelLeftInset
    
    /** 显示刷新状态的label */
    lazy open var stateLabel:UILabel = {
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
    
    /** 获取state状态下的title */
    open func title(state:DKRefreshState) -> String? {
        return self.stateTitles[self.state]
    }
    
    override open func prepare() {
        super.prepare()
        self.addSubview(self.stateLabel)
        // 初始化文字
        self.set(title: Bundle.dk_localized(DKRefreshBackFooterIdleText), state: .idle)
        self.set(title: Bundle.dk_localized(DKRefreshBackFooterPullingText), state: .pulling)
        self.set(title: Bundle.dk_localized(DKRefreshBackFooterRefreshingText), state: .refreshing)
        self.set(title: Bundle.dk_localized(DKRefreshBackFooterNoMoreDataText), state: .noMoreData)
    }
    
    override open func placeSubviews() {
        super.placeSubviews()
        if self.stateLabel.constraints.count > 0 {
            return
        }
        // 状态标签
        self.stateLabel.frame = self.bounds
    }
    
    override open var state: DKRefreshState{
        didSet{
            self.stateLabel.text = self.stateTitles[state]
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
