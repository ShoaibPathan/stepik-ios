//
//  ConnectionHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class ConnectionHelper: NSObject {

    fileprivate override init() {
        super.init()
        reachability = Reachability.forInternetConnection()
        reachability.reachableOnWWAN = reachableOnWWAN

//        reachability.reachableOnWWAN = defaults.objectForKey(reachableOnWWANKey) as? Bool ?? false

        NotificationCenter.default.addObserver(self, selector: #selector(ConnectionHelper.reachabilityChanged(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        reachability.startNotifier()
    }

    fileprivate var reachabilityChangedHandlers: [(Bool) -> Void] = []

    func instantiate() {}

    func addReachabilityChangedHandler(handler : @escaping (Bool) -> Void) {
        reachabilityChangedHandlers.append(handler)
    }

    fileprivate func callReachabilityhandlers(_ result: Bool) {
        for handler in reachabilityChangedHandlers {
            handler(result)
        }
    }

    var isReachable: Bool {
        return self.reachability.isReachableViaWiFi() || (self.reachability.isReachableViaWWAN() && self.reachability.reachableOnWWAN)
    }

    var reachableOnWWAN: Bool {
        get {
            if let r = defaults.object(forKey: reachableOnWWANKey) as? Bool {
                return r
            } else {
                self.reachableOnWWAN = false
                return false
            }
        }

        set(value) {
            defaults.set(value, forKey: reachableOnWWANKey)
            defaults.synchronize()
            reachability.reachableOnWWAN = value
        }
    }

    @objc func reachabilityChanged(_ notification: Foundation.Notification) {
        if isReachable {
            print("Service avalaible!!!")
            callReachabilityhandlers(true)
        } else {
            callReachabilityhandlers(false)
            print("Service unavaliable!!!")
        }
    }

    static let shared = ConnectionHelper()

    var reachability: Reachability!

    fileprivate let defaults = UserDefaults.standard
    fileprivate let reachableOnWWANKey = "reachableOnWWAN"
}
