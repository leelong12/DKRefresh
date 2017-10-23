//
//  ViewController.swift
//  DKRefreshDemo
//
//  Created by lee on 2017/6/21.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit
import DKRefresh

let MJExample00 = "UITableView + 下拉刷新";
let MJExample10 = "UITableView + 上拉刷新";
let MJExample20 = "UICollectionView";
let MJExample30 = "UIWebView";

class DKExampleViewController: UITableViewController {
    
    let examples:Array<Example> = {
        let exam0 = Example.init(header: MJExample00, titles: ["默认", "动画图片", "隐藏时间", "隐藏状态和时间", "自定义文字", "自定义刷新控件"], methods: ["example01", "example02", "example03", "example04", "example05", "example06"], vcClass: NSStringFromClass(DKTableViewController.self) )
        
        let exam1 = Example.init(header: MJExample10, titles: ["默认", "动画图片", "隐藏刷新状态的文字", "全部加载完毕", "禁止自动加载", "自定义文字", "加载后隐藏", "自动回弹的上拉01", "自动回弹的上拉02", "自定义刷新控件(自动刷新)", "自定义刷新控件(自动回弹)"], methods: ["example11", "example12", "example13", "example14", "example15", "example16", "example17", "example18", "example19", "example20", "example21"], vcClass: NSStringFromClass(DKTableViewController.self))
        
        let exam2 = Example.init(header: MJExample20, titles: ["上下拉刷新"], methods: ["example21"], vcClass: NSStringFromClass(DKCollectionViewController.self))
        
        let exam3 = Example.init(header: MJExample30, titles: ["下拉刷新"], methods: ["example31"], vcClass: NSStringFromClass(DKWebViewController.self))
        
        return [exam0, exam1, exam2, exam3];
    }()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return examples.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples[section].titles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return examples[section].header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ID = "example";
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath)
        
        
        cell.textLabel?.text = examples[indexPath.section].titles[indexPath.row];
        
        cell.detailTextLabel?.text = "\(examples[indexPath.section].vcClass!)-\(examples[indexPath.section].methods[indexPath.row])";
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let v = examples[indexPath.section].vcClass
        var vc:UIViewController? = nil
        if (v == NSStringFromClass(DKTableViewController.self)) {
            vc = (NSClassFromString(v!) as! (DKTableViewController.Type)).init();
        } else if (v == NSStringFromClass(DKCollectionViewController.self)){
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize.init(width: 80, height: 80)
            layout.sectionInset = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
            layout.minimumInteritemSpacing = 20;
            layout.minimumLineSpacing = 20;
            vc = DKCollectionViewController(collectionViewLayout: layout)
        }else{
            vc = DKWebViewController();
        }
        vc?.title = examples[indexPath.section].titles[indexPath.row];
        vc?.method = examples[indexPath.section].methods[indexPath.row]
        navigationController?.pushViewController(vc!, animated: true);
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

