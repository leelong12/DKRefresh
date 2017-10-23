//
//  DKRefreshComponent.swift
//  DKRefresh
//
//  Created by lee on 2017/6/21.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit
import Foundation

let DKRefreshLabelLeftInset:CGFloat = 25;
let DKRefreshHeaderHeight:CGFloat = 54.0;
let DKRefreshFooterHeight:CGFloat = 44.0;
let DKRefreshSlowAnimationDuration:TimeInterval = 0.4;
let DKRefreshFastAnimationDuration:TimeInterval = 0.25
let DKRefreshKeyPathContentOffset = "contentOffset";
let DKRefreshKeyPathContentInset = "contentInset";
let DKRefreshKeyPathContentSize = "contentSize";
let DKRefreshKeyPathPanState = "state";

let DKRefreshHeaderLastUpdatedTimeKey = "DKRefreshHeaderLastUpdatedTimeKey";

let DKRefreshHeaderIdleText = "DKRefreshHeaderIdleText"
let DKRefreshHeaderPullingText = "DKRefreshHeaderPullingText"
let DKRefreshHeaderRefreshingText = "DKRefreshHeaderRefreshingText";

let DKRefreshAutoFooterIdleText = "DKRefreshAutoFooterIdleText";
let DKRefreshAutoFooterRefreshingText = "DKRefreshAutoFooterRefreshingText";
let DKRefreshAutoFooterNoMoreDataText = "DKRefreshAutoFooterNoMoreDataText";

let DKRefreshBackFooterIdleText = "DKRefreshBackFooterIdleText";
let DKRefreshBackFooterPullingText = "DKRefreshBackFooterPullingText";
let DKRefreshBackFooterRefreshingText = "DKRefreshBackFooterRefreshingText";
let DKRefreshBackFooterNoMoreDataText = "DKRefreshBackFooterNoMoreDataText";

let DKRefreshHeaderLastTimeText = "DKRefreshHeaderLastTimeText";
let DKRefreshHeaderDateTodayText = "DKRefreshHeaderDateTodayText";
let DKRefreshHeaderNoneLastDateText = "DKRefreshHeaderNoneLastDateText";
// 文字颜色
let DKRefreshLabelTextColor: UIColor = UIColor(red: 90.0/255.0, green: 90.0/255.0, blue: 90.0/255.0, alpha: 1.0)

// 字体大小
let DKRefreshLabelFont:UIFont = UIFont.boldSystemFont(ofSize: 14)

/// 控件状态
///
/// - idle: 普通闲置状态
/// - pulling: 松开就可以进行刷新的状态
/// - refreshing: 正在刷新中的状态
/// - willRefresh: 即将刷新的状态
/// - noMoreData: 所有数据加载完毕，没有更多的数据了
public enum DKRefreshState {
    case idle
    case pulling
    case refreshing
    case willRefresh
    case noMoreData
}

/// 进入刷新状态回调
public typealias DKRefreshComponentRefreshingBlock = ()->Void

/// 开始刷新后的回调(进入刷新状态后的回调)
public typealias DKRefreshComponentbeginRefreshingCompletionBlock = ()->Void

/// 结束刷新后的回调
public typealias DKRefreshComponentEndRefreshingCompletionBlock = ()->Void

open class DKRefreshComponent: UIView {
    
    /// 记录scrollView刚开始的inset
    public var scrollViewOriginalInset :UIEdgeInsets = UIEdgeInsets.zero
    
    /// 父控件
    public weak var scrollView :UIScrollView?
    
    /// 正在刷新回调
    public var refreshingBlock: DKRefreshComponentRefreshingBlock?
    
    /// 回调对象
    public weak var refreshingTarget: AnyObject?
    
    /// 回调方法
    @objc dynamic public var refreshingAction: Selector?
    
    /// 设置回调对象和方法
    ///
    /// - Parameters:
    ///   - target: 回调对象
    ///   - action: 回调方法
    public func refreshing(target:AnyObject,refreshingAction action:Selector) -> Void {
        refreshingTarget = target
        refreshingAction = action
    }
    
    /// 触发回调（交给子类去调用）
    public func executeRefreshingCallback() -> Void {
        DispatchQueue.main.async {
            if self.refreshingBlock != nil{
                self.refreshingBlock!()
            }
            if self.refreshingTarget != nil && self.refreshingAction != nil{
                if self.refreshingTarget!.responds(to: self.refreshingAction!){
                    let _ = self.refreshingTarget!.perform(self.refreshingAction!)
                }
            }
            if self.beginRefreshingCompletionBlock != nil {
                self.beginRefreshingCompletionBlock!()
            }
        }
    }
    
    /// 开始刷新后的回调(进入刷新状态后的回调)
    public var beginRefreshingCompletionBlock: DKRefreshComponentbeginRefreshingCompletionBlock?
    
    /// 进入刷新状态
    ///
    /// - Parameter completionBlock: 开始刷新后的回调(进入刷新状态后的回调)
    public func beginRefreshing(_ completionBlock:DKRefreshComponentbeginRefreshingCompletionBlock? = nil)->Void{
        self.beginRefreshingCompletionBlock = completionBlock
        UIView.animate(withDuration: DKRefreshFastAnimationDuration) { 
            self.alpha = 1.0
        }
        self.pullingPercent = 1.0;
        // 只要正在刷新，就完全显示
        if ((self.window) != nil) {
            self.state = .refreshing;
        } else {
            // 预防正在刷新中时，调用本方法使得header inset回置失败
            if (self.state != .refreshing) {
                self.state = .willRefresh;
                // 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
                setNeedsDisplay()
            }
        }
    }
    
    /// 结束刷新的回调
    public var endRefreshingCompletionBlock: DKRefreshComponentEndRefreshingCompletionBlock?
    
    /// 结束刷新状态
    ///
    /// - Parameter completionBlock: 结束刷新的回调
    public func endRefreshing(_ completionBlock:DKRefreshComponentbeginRefreshingCompletionBlock? = nil)->Void{
        self.endRefreshingCompletionBlock = completionBlock
        self.state = .idle
    }
    
    /// 是否正在刷新
    public var isRefreshing: Bool{
        get{
            return self.state == .refreshing || self.state == .willRefresh
        }
    }
    
    private var _state :DKRefreshState = DKRefreshState.idle
    /// 刷新状态 一般交给子类内部实现
    open var state :DKRefreshState{
        get{
            return _state
        }
        set{
            _state = newValue
            DispatchQueue.main.async {
                self.setNeedsLayout()
            }
        }
    }
    
    
    //MARK - 交给子类们去实现
    /// 初始化
    open func prepare() -> Void {
        // 基本属性
        self.autoresizingMask = .flexibleWidth
        self.backgroundColor = UIColor.clear
    }
    
    open func placeSubviews() -> Void {
        
    }
    /// 当scrollView的contentOffset发生改变的时候调用
    ///
    /// - Parameter change: <#change description#>
    open func scrollViewContentOffsetDidChange(_ change:Dictionary<NSKeyValueChangeKey, Any>?) -> Void {
        
    }
    
    /// 当scrollView的contentSize发生改变的时候调用
    ///
    /// - Parameter change: <#change description#>
    open func scrollViewContentSizeDidChange(_ change:Dictionary<NSKeyValueChangeKey, Any>?) -> Void {
        
    }
    
    /// 当scrollView的拖拽状态发生改变的时候调用
    ///
    /// - Parameter change: <#change description#>
    open func scrollViewPanStateDidChange(_ change:Dictionary<NSKeyValueChangeKey, Any>?) -> Void {
        
    }
    
    var _pullingPercent:CGFloat = 0.0
    
    /// 拉拽的百分比(交给子类重写)
    open var pullingPercent:CGFloat{
        get{
            return _pullingPercent
        }
        set{
            _pullingPercent = newValue
            if (self.isRefreshing) {return}
            
            if (self.isAutomaticallyChangeAlpha) {
                self.alpha = newValue
            }
        }
    }
    
    var _isAutomaticallyChangeAlpha:Bool = false
    
    /// 根据拖拽比例自动切换透明度
    public var isAutomaticallyChangeAlpha:Bool{
        get{
            return _isAutomaticallyChangeAlpha
        }
        set{
            _isAutomaticallyChangeAlpha = newValue
            if (self.isRefreshing) {return}
            
            if (newValue) {
                self.alpha = self.pullingPercent;
            } else {
                self.alpha = 1.0;
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    open override func layoutSubviews() {
        placeSubviews()
        super.layoutSubviews()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        // 如果不是UIScrollView，不做任何事情
        if newSuperview != nil {
            if !(newSuperview!.isKind(of: UIScrollView.self)){
                return
            }
        }
        
        // 旧的父控件移除监听
        removeObservers()
        
        if newSuperview != nil { // 新的父控件
            // 设置宽度
            self.dk_w = newSuperview!.dk_w;
            // 设置位置
            self.dk_x = 0;
            
            // 记录UIScrollView
            self.scrollView = newSuperview as? UIScrollView
            // 设置永远支持垂直弹簧效果
            self.scrollView?.alwaysBounceVertical = true;
            // 记录UIScrollView最开始的contentInset
            self.scrollViewOriginalInset = scrollView?.contentInset ?? UIEdgeInsets.zero
            
            // 添加监听
            self.addObservers()
        }
    }
    
    var pan: UIPanGestureRecognizer?
    
    //MARK - KVO监听
    func addObservers() -> Void {
        let options:NSKeyValueObservingOptions = [.new,.old]
        self.scrollView?.addObserver(self, forKeyPath: DKRefreshKeyPathContentOffset, options: options, context: nil)
        self.scrollView?.addObserver(self, forKeyPath: DKRefreshKeyPathContentSize, options: options, context: nil)
        self.pan = self.scrollView?.panGestureRecognizer
        self.pan?.addObserver(self, forKeyPath: DKRefreshKeyPathPanState, options: options, context: nil)
    }
    
    func removeObservers() -> Void {
        self.superview?.removeObserver(self, forKeyPath: DKRefreshKeyPathContentOffset)
        self.superview?.removeObserver(self, forKeyPath: DKRefreshKeyPathContentSize)
        self.pan?.removeObserver(self, forKeyPath: DKRefreshKeyPathPanState)
        self.pan = nil;
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if (self.state == .willRefresh) {
            // 预防view还没显示出来就调用了beginRefreshing
            self.state = .refreshing;
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // 遇到这些情况就直接返回
        if (!self.isUserInteractionEnabled) {return}
        
        // 这个就算看不见也需要处理
        if keyPath != nil {
            if keyPath! == DKRefreshKeyPathContentSize {
                scrollViewContentSizeDidChange(change)
            }
            // 看不见
            if (self.isHidden) {return}
            if keyPath! ==  DKRefreshKeyPathContentOffset{
                scrollViewContentOffsetDidChange(change)
            }else if ( keyPath! == DKRefreshKeyPathPanState){
                scrollViewPanStateDidChange(change)
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

public extension UIView{
    public var dk_x:CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            var frame = self.frame;
            frame.origin.x = newValue;
            self.frame = frame;
        }
    }
    
    public var dk_y:CGFloat{
        get{
            return self.frame.origin.y
        }
        set{
            var frame = self.frame;
            frame.origin.y = newValue;
            self.frame = frame;
        }
    }
    
    public var dk_w:CGFloat{
        get{
            return self.frame.size.width
        }
        set{
            var frame = self.frame;
            frame.size.width = newValue;
            self.frame = frame;
        }
    }
    
    public var dk_h:CGFloat{
        get{
            return self.frame.size.height
        }
        set{
            var frame = self.frame;
            frame.size.height = newValue;
            self.frame = frame;
        }
    }
    
    public var dk_size:CGSize{
        get{
            return self.frame.size
        }
        set{
            var frame = self.frame;
            frame.size = newValue;
            self.frame = frame;
        }
    }
    
    public var dk_origin:CGPoint{
        get{
            return self.frame.origin
        }
        set{
            var frame = self.frame;
            frame.origin = newValue;
            self.frame = frame;
        }
    }
}
