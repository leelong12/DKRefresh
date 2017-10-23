//
//  DKTableViewController.swift
//  DKRefreshDemo
//
//  Created by lee on 2017/10/18.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit
import DKRefresh

class DKTableViewController: UITableViewController {

    func random() -> String {
        return "随机数据---\(arc4random_uniform(1000000))"
    }
    
    lazy var data:Array<String> = {
        var data:Array<String> = Array();
        for _ in 0...5{
            data.append(self.random())
        }
        return data
    }()
    
    @objc func example01() -> Void {
        tableView.dk_header = DKRefreshNormalHeader.header { [weak self] in
            self?.loadNewData();
        }
        tableView.dk_header?.beginRefreshing();
    }
    
    @objc func example02() -> Void {
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
        tableView.dk_header = DKChiBaoZiHeader.header(target: self, action: #selector(loadNewData));
        
        // 马上进入刷新状态
        tableView.dk_header?.beginRefreshing()
    }
    
    @objc func example03() -> Void {
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
        let header:DKRefreshNormalHeader = DKRefreshNormalHeader.header(target: self, action: #selector(loadNewData)) as! DKRefreshNormalHeader
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.isAutomaticallyChangeAlpha = true;
        
        // 隐藏时间
        header.lastUpdatedTimeLabel.isHidden = true;
        
        // 马上进入刷新状态
        header.beginRefreshing()
        
        // 设置header
        tableView.dk_header = header;
        
    }
    
    @objc func example04() -> Void {
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
        let header:DKChiBaoZiHeader = DKChiBaoZiHeader.header(target: self, action: #selector(loadNewData)) as! DKChiBaoZiHeader
        
        // 隐藏时间
        header.lastUpdatedTimeLabel.isHidden = true;
        
        // 隐藏状态
        header.stateLabel.isHidden = true;
        
        // 马上进入刷新状态
        header.beginRefreshing()
        
        // 设置header
        tableView.dk_header = header;
    }
    
    @objc func example05() -> Void {
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
        let header:DKRefreshNormalHeader = DKRefreshNormalHeader.header(target: self, action: #selector(loadNewData)) as! DKRefreshNormalHeader
        
        // 设置文字
        header.set(title: "Pull down to refresh", state: .idle)
        header.set(title: "Release to refresh", state: .pulling)
        header.set(title: "Loading ...", state: .refreshing)
        
        // 设置字体
        header.stateLabel.font = UIFont.systemFont(ofSize: 15)
        header.lastUpdatedTimeLabel.font = UIFont.systemFont(ofSize: 14)
        
        // 设置颜色
        header.stateLabel.textColor = UIColor.red
        header.lastUpdatedTimeLabel.textColor = UIColor.blue
        
        // 马上进入刷新状态
        header.beginRefreshing()
        
        // 设置刷新控件
        tableView.dk_header = header;
    }
    
    @objc func example06() -> Void {
        tableView.dk_header = DKDIYHeader.header(target: self, action: #selector(loadNewData))
        tableView.dk_header?.beginRefreshing()
    }
    
    @objc func example11() -> Void {
        example01();
        // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
        tableView.dk_footer = DKRefreshAutoNormalFooter.footer { [weak self] in
            self?.loadMoreData();
        }
    }
    
    @objc func example12() -> Void {
        example01();
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        tableView.dk_footer = DKChiBaoZiFooter.footer(target: self, action: #selector(loadMoreData))
    }
    
    @objc func example13() -> Void {
        example01();
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        let footer:DKChiBaoZiFooter = DKChiBaoZiFooter.footer(target: self, action: #selector(loadMoreData)) as! DKChiBaoZiFooter
        
        // 当上拉刷新控件出现50%时（出现一半），就会自动刷新。这个值默认是1.0（也就是上拉刷新100%出现时，才会自动刷新）
            footer.triggerAutomaticallyRefreshPercent = 0.5;
        
        // 隐藏刷新状态的文字
        footer.isRefreshingTitleHidden = true;
        
        // 设置footer
        self.tableView.dk_footer = footer;
    }
    
    @objc func example14() -> Void {
        example01();
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadLastData方法）
        tableView.dk_footer = DKRefreshAutoNormalFooter.footer(target: self, action: #selector(loadLastData))
        
        // 其他
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "恢复数据加载", style: .done, target: self, action: #selector(reset))
    }
    
    @objc func reset() -> Void {
        tableView.dk_footer?.refreshing(target: self, refreshingAction: #selector(loadMoreData))
        tableView.dk_footer?.resetNoMoreData()
    }
    
    @objc func example15() -> Void {
        example01();
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        let footer:DKRefreshAutoNormalFooter = DKRefreshAutoNormalFooter.footer(target: self, action: #selector(loadMoreData)) as! DKRefreshAutoNormalFooter
        
        // 禁止自动加载
        footer.isAutomaticallyRefresh = false;
        
        // 设置footer
        tableView.dk_footer = footer;
        
    }
    
    @objc func example16() -> Void {
        example01();
        // 添加默认的上拉刷新
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        let footer:DKRefreshAutoNormalFooter = DKRefreshAutoNormalFooter.footer(target: self, action: #selector(loadMoreData)) as! DKRefreshAutoNormalFooter
        
        // 设置文字
        footer.set(title: "Click or drag up to refresh", state: .idle)
        footer.set(title: "Loading more ...", state: .refreshing)
        footer.set(title: "No more data", state: .noMoreData)
        
        // 设置字体
        footer.stateLabel.font = UIFont.systemFont(ofSize: 17)
        
        // 设置颜色
        footer.stateLabel.textColor = UIColor.blue
        
        // 设置footer
        tableView.dk_footer = footer;
    }
    
    @objc func example17() -> Void {
         example01();
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadOnceData方法）
        tableView.dk_footer = DKRefreshAutoNormalFooter.footer(target: self, action: #selector(loadOnceData))
    }
    
    @objc func example18() -> Void {
        example01();
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        tableView.dk_footer = DKRefreshBackNormalFooter.footer(target: self, action: #selector(loadMoreData))
        // 设置了底部inset
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 30, right: 0)
        // 忽略掉底部inset
        if #available(iOS 11.0, *) {
            print(tableView.adjustedContentInset.bottom)
        } else {
            // Fallback on earlier versions
        };
        tableView.dk_footer?.ignoredScrollViewContentInsetBottom = 30;
    }
    
    @objc func example19() -> Void {
        example01();
        tableView.dk_footer = DKChiBaoZiFooter2.footer(target: self, action: #selector(loadLastData))
        tableView.dk_footer?.isAutomaticallyChangeAlpha = true
    }
    
    @objc func example20() -> Void {
        example01();
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        tableView.dk_footer = DKDIYAutoFooter.footer(target: self, action: #selector(loadMoreData))
    }
    
    @objc func example21() -> Void {
        example01();
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        tableView.dk_footer = DKDIYBackFooter.footer(target: self, action: #selector(loadMoreData))
    }
    
    @objc func loadNewData() -> Void {
        // 1.添加假数据
        for _ in 0..<5 {
            data.insert(random(), at: 0)
        }
        
        // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) { [weak self] in
            // 刷新表格
            self?.tableView.reloadData()
            // 拿到当前的下拉刷新控件，结束刷新状态
            self?.tableView.dk_header?.endRefreshing(nil);
        }
    }
    
    @objc func loadMoreData() -> Void {
        // 1.添加假数据
        for _ in 0..<5 {
            data.append(random())
        }
        
        // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) { [weak self] in
            // 刷新表格
            self?.tableView.reloadData()
            // 拿到当前的上拉刷新控件，结束刷新状态
            self?.tableView.dk_footer?.endRefreshing(nil);
        }
    }
    
    @objc func loadLastData() -> Void {
        // 1.添加假数据
        for _ in 0..<5 {
            data.append(random())
        }
        
        // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) { [weak self] in
            // 刷新表格
            self?.tableView.reloadData()
            // 拿到当前的上拉刷新控件，变为没有更多数据的状态
            self?.tableView.dk_footer?.endRefreshingWithNoMoreData()
        }
    }
    
    @objc func loadOnceData() -> Void {
        // 1.添加假数据
        for _ in 0..<5 {
            data.append(random())
        }
        
        // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) { [weak self] in
            // 刷新表格
            self?.tableView.reloadData()
            // 隐藏当前的上拉刷新控件
            self?.tableView.dk_footer?.isHidden = true;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        perform(NSSelectorFromString(self.method!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = "\(data[indexPath.row])";
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
