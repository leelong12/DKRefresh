//
//  DKRefreshStateHeader.swift
//  DKRefresh
//
//  Created by lee on 2017/6/22.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit

open class DKRefreshStateHeader: DKRefreshHeader {
    //MARK - 刷新时间相关
    /** 利用这个block来决定显示的更新时间文字 */
    public var lastUpdatedTimeText :((Date)->String)?
    /** 显示上一次刷新时间的label */
    lazy public var lastUpdatedTimeLabel :UILabel = {
        let label = UILabel.dk_label()
        self.addSubview(label)
        return label
    }()
    
    //MARK - 状态相关
    /** 文字距离圈圈、箭头的距离 */
    public var labelLeftInset :CGFloat = DKRefreshLabelLeftInset
    /** 显示刷新状态的label */
    lazy public var stateLabel: UILabel = {
        let label = UILabel.dk_label()
        self.addSubview(label)
        return label
    }()
    
    /** 所有状态对应的文字 */
    public var stateTitles:Dictionary<DKRefreshState,String> = Dictionary()
    /** 设置state状态下的文字 */
    public func set(title:String,state:DKRefreshState) -> Void {
        self.stateTitles[state] = title
        self.stateLabel.text = self.stateTitles[self.state]
    }
    
    var currentCalendar :Calendar{
        if #available(iOS 8.0, *) {
            return Calendar.init(identifier: .gregorian)
        } else {
            return Calendar.current
        }
    }
    
    override var lastUpdatedTimeKey: String{
        get{
            return super.lastUpdatedTimeKey
        }
        set{
            super.lastUpdatedTimeKey = newValue
            // 如果label隐藏了，就不用再处理
            if (self.lastUpdatedTimeLabel.isHidden) {return}
            
            if let lastUpdatedTime = UserDefaults.standard.object(forKey: lastUpdatedTimeKey) as? Date {
                // 如果有block
                if self.lastUpdatedTimeText != nil {
                    self.lastUpdatedTimeLabel.text = self.lastUpdatedTimeText!(lastUpdatedTime)
                    return
                }
                // 1.获得年月日
                let calendar = currentCalendar
                
                let unitFlags = Set.init(arrayLiteral: Calendar.Component.year,Calendar.Component.month,Calendar.Component.day,Calendar.Component.hour,Calendar.Component.minute)
                let cmp1 = calendar.dateComponents(unitFlags, from: lastUpdatedTime)
                let cmp2 = calendar.dateComponents(unitFlags, from: Date())
                // 2.格式化日期
                let formatter = DateFormatter()
                var isToday = false
                if cmp1.day != nil && cmp2.day != nil && cmp1.day! == cmp2.day! { //今天
                    formatter.dateFormat = " HH:mm"
                    isToday = true
                }else if cmp1.year != nil && cmp2.year != nil && cmp1.year! == cmp2.year! { //今年
                    formatter.dateFormat = "MM-dd HH:mm"
                }else{
                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                }
                let time = formatter.string(from: lastUpdatedTime)
                // 3.显示日期
                self.lastUpdatedTimeLabel.text = "\(Bundle.dk_localized(DKRefreshHeaderLastTimeText))\(isToday ? Bundle.dk_localized(DKRefreshHeaderDateTodayText) : "")\(time)"
            }else{
                self.lastUpdatedTimeLabel.text = "\(Bundle.dk_localized(DKRefreshHeaderLastTimeText))\(Bundle.dk_localized(DKRefreshHeaderNoneLastDateText))"
            }
        }
    }
    
    //MARK -覆盖父类的方法
    
    override open func prepare() {
        super.prepare()
        // 初始化间距
        self.labelLeftInset = DKRefreshLabelLeftInset;
        
        // 初始化文字
        self.set(title: Bundle.dk_localized(DKRefreshHeaderIdleText), state: .idle)
        self.set(title: Bundle.dk_localized(DKRefreshHeaderPullingText), state: .pulling)
        self.set(title: Bundle.dk_localized(DKRefreshHeaderRefreshingText), state: .refreshing)
    }
    
    override open func placeSubviews() {
        super.placeSubviews()
        if (self.stateLabel.isHidden) {return}
        
        let noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0
        
        if (self.lastUpdatedTimeLabel.isHidden) {
            // 状态
            if (noConstrainsOnStatusLabel) {self.stateLabel.frame = self.bounds}
        } else {
            let stateLabelH = self.dk_h * 0.5;
            // 状态
            if (noConstrainsOnStatusLabel) {
                self.stateLabel.dk_x = 0;
                self.stateLabel.dk_y = 0;
                self.stateLabel.dk_w = self.dk_w;
                self.stateLabel.dk_h = stateLabelH;
            }
            
            // 更新时间
            if (self.lastUpdatedTimeLabel.constraints.count == 0) {
                self.lastUpdatedTimeLabel.dk_x = 0;
                self.lastUpdatedTimeLabel.dk_y = stateLabelH;
                self.lastUpdatedTimeLabel.dk_w = self.dk_w;
                self.lastUpdatedTimeLabel.dk_h = self.dk_h - self.lastUpdatedTimeLabel.dk_y;
            }
        }
    }
    
    open override var state: DKRefreshState{
        didSet{
            // 设置状态文字
            self.stateLabel.text = self.stateTitles[state];
            
            // 重新设置key（重新显示时间）
            self.lastUpdatedTimeKey = DKRefreshHeaderLastUpdatedTimeKey
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
