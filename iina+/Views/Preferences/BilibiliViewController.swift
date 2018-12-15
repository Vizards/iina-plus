//
//  BilibiliViewController.swift
//  iina+
//
//  Created by xjbeta on 2018/8/7.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

class BilibiliViewController: NSViewController {

    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var bilibiliUserNameTextField: NSTextField!
    @IBOutlet weak var douyuUserNameTextField: NSTextField!
    @IBOutlet weak var douyuTabView: NSTabView!
    @IBOutlet weak var bilibiliTabView: NSTabView!
    
    @IBAction func bilibiliLogout(_ sender: Any) {
        bilibili.logout().done { _ in
            self.initStatus()
            }.catch { error in
                Logger.log("Logout bilibili error: \(error)")
                self.selectTabViewItem(.error)
        }
    }
    
    @IBAction func douyuLogout(_ sender: Any) {
        let url = URL(string: "https://www.douyu.com")
        douyu.logout().done { _ in
            self.clearCookies(url!)
            self.initStatus()
            }.catch { error in
                Logger.log("Logout douyu error: \(error)")
                self.selectTabViewItem(.error)
        }
    }
    
    @IBAction func tryAgain(_ sender: Any) {
        initStatus()
    }
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    enum BiliBiliTabs: Int {
        case account, error, progress
    }
    let bilibili = Bilibili()
    let douyu = Douyu()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initStatus()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? BilibiliLoginViewController {
            vc.dismiss = {
                self.dismiss(vc)
                self.initStatus()
            }
        }
        if let vc = segue.destinationController as? DouyuLoginViewController {
            vc.dismiss = {
                self.dismiss(vc)
                self.initStatus()
            }
        }
    }
    
    func clearCookies(_ url: URL) {
        let cstorage = HTTPCookieStorage.shared
        if let cookies = cstorage.cookies(for: url) {
            for cookie in cookies {
                cstorage.deleteCookie(cookie)
            }
        }
        
//        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
//            records.forEach { record in
//                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
//            }
//        }
    }
    
    func initStatus() {
        selectTabViewItem(.progress)
        selectTabViewItem(.account)
        
        bilibili.isLogin().done(on: .main) {
            if $0.0 {
                self.bilibiliTabView.selectTabViewItem(at: 1)
            } else {
                self.bilibiliTabView.selectTabViewItem(at: 0)
            }
            self.bilibiliUserNameTextField.stringValue = $0.1
            }.catch { error in
                Logger.log("Init bilibili status error: \(error)")
                self.selectTabViewItem(.error)
        }
        
        douyu.isLogin().done(on: .main) {
            if $0.0 {
                Logger.log("Logged")
                self.douyuTabView.selectTabViewItem(at: 1)
            } else {
                self.douyuTabView.selectTabViewItem(at: 0)
            }
            self.douyuUserNameTextField.stringValue = $0.1
            }.catch { error in
                Logger.log("Init douyu status error: \(error)")
                self.selectTabViewItem(.error)
        }
    }
    
    func selectTabViewItem(_ tab: BiliBiliTabs) {
        DispatchQueue.main.async {
            if tab == .progress {
                self.progressIndicator.startAnimation(nil)
            }
            self.tabView.selectTabViewItem(at: tab.rawValue)
        }
    }
    
}
