//
//  DKCollectionViewController.swift
//  DKRefreshDemo
//
//  Created by lee on 2017/10/19.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit
import DKRefresh
private let reuseIdentifier = "Cell"

class DKCollectionViewController: UICollectionViewController {

    func randomColor() -> UIColor {
        return UIColor.init(red: CGFloat(arc4random_uniform(255))/255.0, green: CGFloat(arc4random_uniform(255))/255.0, blue: CGFloat(arc4random_uniform(255))/255.0, alpha: 1)
    }
    
    lazy var colors:Array<UIColor> = Array()
    
    @objc func example21() -> Void {
        // 下拉刷新
        self.collectionView?.dk_header = DKRefreshNormalHeader.header { [weak self] in
            // 增加10条假数据
            for _ in 0..<10 {
                self?.colors.insert((self?.randomColor())!, at: 0)
            }
            // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0, execute: {
                self?.collectionView?.reloadData()
                // 结束刷新
                self?.collectionView?.dk_header?.endRefreshing(nil)
            })
        }
        self.collectionView?.dk_header?.beginRefreshing()
        
        // 上拉刷新
        self.collectionView?.dk_footer = DKRefreshBackNormalFooter.footer { [weak self] in
            // 增加5条假数据
            for _ in 0..<10 {
                self?.colors.append((self?.randomColor())!)
            }
            // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0, execute: {
                self?.collectionView?.reloadData()
                // 结束刷新
                self?.collectionView?.dk_footer?.endRefreshing(nil)
            })
        }
        // 默认先隐藏footer
        self.collectionView?.dk_footer?.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize.init(width: 80, height: 80)
//        layout.sectionInset = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
//        layout.minimumInteritemSpacing = 20;
//        layout.minimumLineSpacing = 20;
//        self.collectionView!.setCollectionViewLayout(layout, animated: false)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.backgroundColor = UIColor.white
        perform(NSSelectorFromString(self.method!))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        // 设置尾部控件的显示和隐藏
        self.collectionView?.dk_footer?.isHidden = self.colors.count == 0;
        return self.colors.count;
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        cell.backgroundColor = self.colors[indexPath.row];
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
