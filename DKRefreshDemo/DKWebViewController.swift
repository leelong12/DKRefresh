//
//  DKWebViewController.swift
//  DKRefreshDemo
//
//  Created by lee on 2017/10/20.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit
import DKRefresh
class DKWebViewController: UIViewController {
    
    lazy var webView:UIWebView = {
        let webView = UIWebView()
        self.view.addSubview(webView)
        return webView
    }()
    
    @objc func example31() -> Void {
        // 添加下拉刷新控件
        webView.scrollView.dk_header = DKRefreshNormalHeader.header { [weak self] in
            self?.webView.reload();
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.frame = view.bounds
        webView.delegate = self
        // 加载页面
        webView.loadRequest(URLRequest.init(url: URL.init(string: "https://www.baidu.com")!))
        perform(NSSelectorFromString(self.method!))
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            print(webView.scrollView.adjustedContentInset.bottom)
            print(webView.scrollView.contentInset.bottom)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DKWebViewController:UIWebViewDelegate{
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.scrollView.dk_header?.endRefreshing(nil);
        if #available(iOS 11.0, *) {
            print(webView.scrollView.adjustedContentInset.bottom)
            print(webView.scrollView.contentInset.bottom)
        } else {
            // Fallback on earlier versions
        }
    }
}
