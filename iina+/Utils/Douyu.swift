//
//  Douyu.swift
//  iina+
//
//  Created by Vizards on 2018/12/14.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa
import SwiftHTTP
import Marshal
import PromiseKit

class Douyu: NSObject {
    
    func isLogin() -> Promise<(Bool, String)> {
        return Promise { resolver in
            HTTP.GET("https://www.douyu.com/member/cp/cp_rpc_ajax")
            { response in
                if let error = response.error {
                    resolver.reject(error)
                }
                
                do {
                    let json: JSONObject = try
                        JSONParser.JSONObjectWithData(response.data)
                    let isLogin: Bool = try json.value(for: "info.isNeedConfirmPhone")
                    
                    resolver.fulfill((!isLogin, try json.value(for: "info.email")))
                } catch {
                    resolver.fulfill((false, ""))
                }
            }
        }
    }
    
    func logout() -> Promise<()> {
        return Promise { resolver in
            HTTP.GET("https://passport.douyu.com/sso/logout?client_id=1")
            { response in
                if let error = response.error {
                    resolver.reject(error)
                }
                resolver.fulfill(())
            }
        }
    }
}
