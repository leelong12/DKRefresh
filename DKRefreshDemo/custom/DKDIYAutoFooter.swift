//
//  DKDIYAutoFooter.swift
//  DKRefreshDemo
//
//  Created by lee on 2017/10/19.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit
import DKRefresh
class DKDIYAutoFooter: DKRefreshAutoFooter {

    var label:UILabel?
    var s:UISwitch?
    var loading:UIActivityIndicatorView?
    
    override func prepare() {
        super.prepare()
        // 设置控件的高度
        self.dk_h = 50;
        
        // 添加label
        let label = UILabel()
        label.textColor = UIColor.init(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "赶紧上拉吖(开关是打酱油滴)"
        label.textAlignment = .center;
        addSubview(label)
        self.label = label;
        
        // 打酱油的开关
        let s = UISwitch();
        addSubview(s);
        self.s = s;
        
        // loading
        let loading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        addSubview(loading)
        self.loading = loading;
    }
    
    override open func placeSubviews() {
        super.placeSubviews()
        self.label?.frame = self.bounds;
        self.s?.center = CGPoint.init(x: self.dk_w-20, y: self.dk_h-20)
        self.loading?.center = CGPoint.init(x: 30, y: self.dk_h * 0.5)
    }
    
    override var state: DKRefreshState{
        didSet{
            switch state {
            case .idle:
                self.loading?.stopAnimating()
                self.s?.setOn(false, animated: true)
                self.label?.text = "赶紧上拉吖(开关是打酱油滴)"
            case .pulling:
                self.loading?.stopAnimating()
                self.s?.setOn(true, animated: true)
                self.label?.text = "赶紧放开我吧(开关是打酱油滴)"
            case .refreshing:
                self.s?.setOn(true, animated:true)
                self.label?.text = "加载数据中(开关是打酱油滴)"
                self.loading?.startAnimating()
            case .noMoreData:
                self.label?.text = "木有数据了(开关是打酱油滴)"
                self.s?.setOn(false, animated: true)
                self.loading?.stopAnimating()
            default: break
            }
        }
    }
    
    override var pullingPercent: CGFloat{
        didSet{
            let red:CGFloat = 1.0 - pullingPercent * 0.5;
            let green:CGFloat = 0.5 - 0.5 * pullingPercent;
            let blue:CGFloat = 0.5 * pullingPercent;
            self.label?.textColor = UIColor.init(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }

}
