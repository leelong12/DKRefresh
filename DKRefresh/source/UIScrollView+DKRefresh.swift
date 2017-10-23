//
//  UIScrollView+DKRefresh.swift
//  DKRefresh
//
//  Created by lee on 2017/6/21.
//  Copyright © 2017年 lee. All rights reserved.
//

import Foundation

extension Bundle{
    static func dk_refreshBundle()->Bundle?{
        let refreshBundle = Bundle.init(path: Bundle.init(for: DKRefreshComponent.self).path(forResource: "DKRefresh", ofType: "bundle")!)
        return refreshBundle
    }
    
    static func dk_arrowImage()->UIImage?{
        let arrowImage = UIImage.init(contentsOfFile: (self.dk_refreshBundle()?.path(forResource: "arrow@2x", ofType: "png")!) ?? "")
        return arrowImage
    }
    
    static func dk_localized(_ key:String ,value:String? = nil) -> String {
        var bundle :Bundle?
        // （iOS获取的语言字符串比较不稳定）目前框架只处理en、zh-Hans、zh-Hant三种情况，其他按照系统默认处理
        if var language = Locale.preferredLanguages.first{
            if language.hasPrefix("en") {
                language = "en"
            }else if language.hasPrefix("zh"){
                if (language.range(of: "Hans") != nil) {
                    language = "zh-Hans" // 简体中文
                }else{// zh-Hant\zh-HK\zh-TW
                    language = "zh-Hant" // 繁體中文
                }
            }else{
                language = "en"
            }
            bundle = Bundle.init(path: (Bundle.dk_refreshBundle()?.path(forResource: language, ofType: "lproj"))!)
        }
        let newValue = bundle?.localizedString(forKey: key, value: value, table: nil)
        return Bundle.main.localizedString(forKey: key, value: newValue, table: nil)
    }
}

extension UILabel{
    static func dk_label() -> UILabel {
        let label = UILabel()
        label.font = DKRefreshLabelFont
        label.textColor = DKRefreshLabelTextColor
        label.autoresizingMask = .flexibleWidth
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        return label;
    }
    
    func dk_textWith() -> CGFloat {
        var stringWidth:CGFloat = 0
        let size = CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT))
        if ((self.text ?? "").lengthOfBytes(using: .utf8) > 0) {
            stringWidth = (self.text! as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: Dictionary(dictionaryLiteral: (NSAttributedStringKey.font, self.font)), context: nil).size.width
        }
        return stringWidth
    }
}

public extension UIScrollView{
    
    var dk_inset :UIEdgeInsets{
        if #available(iOS 11.0, *) {
            return self.adjustedContentInset
        } else {
            // Fallback on earlier versions
            return self.contentInset;
        };
    }
    
    var dk_insetT :CGFloat{
        get{
            return self.dk_inset.top
        }
        set{
            var inset = self.contentInset
            inset.top = newValue
            if #available(iOS 11.0, *){
                inset.top -= (self.adjustedContentInset.top - self.contentInset.top)
            }
            self.contentInset = inset
        }
    }
    
    var dk_insetB :CGFloat{
        get{
            return self.dk_inset.bottom
        }
        set{
            var inset = self.contentInset
            inset.bottom = newValue
            if #available(iOS 11.0, *){
                inset.bottom -= (self.adjustedContentInset.bottom - self.contentInset.bottom)
            }
            self.contentInset = inset
        }
    }
    
    var dk_insetL :CGFloat{
        get{
            return self.contentInset.left
        }
        set{
            var inset = self.contentInset
            inset.left = newValue
            if #available(iOS 11.0, *){
                inset.left -= (self.adjustedContentInset.left - self.contentInset.left)
            }
            self.contentInset = inset
        }
    }
    
    var dk_insetR :CGFloat{
        get{
            return self.contentInset.right
        }
        set{
            var inset = self.contentInset
            inset.right = newValue
            if #available(iOS 11.0, *){
                inset.right -= (self.adjustedContentInset.right - self.contentInset.right)
            }
            self.contentInset = inset
        }
    }
    
    var dk_offsetX: CGFloat {
        get {
            return self.contentOffset.x
        }
        set {
            var offset = self.contentOffset
            offset.x = newValue
            self.contentOffset = offset
        }
    }
    
    var dk_offsetY: CGFloat {
        get {
            return self.contentOffset.y
        }
        set {
            var offset = self.contentOffset
            offset.y = newValue
            self.contentOffset = offset
        }
    }
    
    var dk_contentW: CGFloat {
        get {
            return self.contentSize.width
        }
        set {
            var size = self.contentSize
            size.width = newValue
            self.contentSize = size
        }
    }
    
    var dk_contentH: CGFloat {
        get {
            return self.contentSize.height
        }
        set {
            var size = self.contentSize
            size.height = newValue
            self.contentSize = size
        }
    }
    
    func dk_totalDataCount() -> Int {
        var totalCount = 0
        if (self.isKind(of: UITableView.self)) {
            let tableView = self as! UITableView
            var section = 0
            while section < tableView.numberOfSections {
                totalCount += tableView.numberOfRows(inSection: section)
                section += 1
            }
        } else if (self.isKind(of: UICollectionView.self)) {
            let collectionView = self as! UICollectionView
            
            var section = 0
            while section < collectionView.numberOfSections {
                totalCount += collectionView.numberOfItems(inSection: section)
                section += 1
            }
        }
        return totalCount
    }
    
    // 改进写法【推荐】
    struct RuntimeKey {
        static let DKRefreshHeaderKey = UnsafeRawPointer.init(bitPattern: "DKRefreshHeaderKey".hashValue)
        static let DKRefreshFooterKey = UnsafeRawPointer.init(bitPattern: "DKRefreshFooterKey".hashValue)
        /// ...其他Key声明
    }
    
    public var dk_header:DKRefreshHeader?{
        get{
            return objc_getAssociatedObject(self, UIScrollView.RuntimeKey.DKRefreshHeaderKey!) as? DKRefreshHeader
        }
        set{
            if self.dk_header != newValue {
                // 删除旧的，添加新的
                self.dk_header?.removeFromSuperview()
                self.insertSubview(newValue!, at: 0)
                //存储新的
                self.willChangeValue(forKey: "dk_header")
                objc_setAssociatedObject(self, UIScrollView.RuntimeKey.DKRefreshHeaderKey!, newValue, .OBJC_ASSOCIATION_ASSIGN)
                self.didChangeValue(forKey: "dk_header")
            }
        }
    }
    
    public var dk_footer:DKRefreshFooter?{
        get{
            return objc_getAssociatedObject(self, UIScrollView.RuntimeKey.DKRefreshFooterKey!) as? DKRefreshFooter
        }
        set{
            if self.dk_footer != newValue {
                // 删除旧的，添加新的
                self.dk_footer?.removeFromSuperview()
                self.insertSubview(newValue!, at: 0)
                //存储新的
                self.willChangeValue(forKey: "dk_footer")
                objc_setAssociatedObject(self, UIScrollView.RuntimeKey.DKRefreshFooterKey!, newValue, .OBJC_ASSOCIATION_ASSIGN)
                self.didChangeValue(forKey: "dk_footer")
            }
        }
    }
}
