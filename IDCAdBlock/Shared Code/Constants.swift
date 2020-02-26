//
//  Constants.swift
//  Sift
//
//  Created by Alex Grinman on 12/24/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import Foundation
import UIKit
import KeychainAccess

struct Constants {
    static let appGroupIdentifier = "group.idc.ac.il.idcAdBLock.shared"
    static let notificationCategory = "network_request_category"
    static let onboardingKey = "\(Bundle.main.bundleIdentifier!)"
    static let pushActivityKey = "push_activity_key"
    static var collectionTimeInterval = TimeInterval(300)
    static var notificationTimeInterval = TimeInterval(1800)
    
    static var didOnboard: Bool {
        return UserDefaults.standard.bool(forKey: Constants.onboardingKey)
    }
    
    static var deviceIdentifier: String {
        let key = "idc.ac.il.deviceId"
        if let id = UserDefaults.standard.string(forKey: key) {
            return id
        }
        
        let id = (UIDevice.current.identifierForVendor ?? UUID()).uuidString
        UserDefaults.standard.set(id, forKey: key)
        return id
    }

    enum NotificationAction:String {
        case edit = "network_request_edit_action"
        
        case allowThis = "network_request_allow_action"
        case allowHost = "network_request_allow_host_action"
        case allowApp = "network_request_allow_app_action"
        
        case denyThis = "network_request_deny_action"
        case denyHost = "network_request_deny_host_action"
        case denyApp = "network_request_deny_app_action"

        var id:String { return self.rawValue }
    }
    
    enum ObservableNotification {
        case appBecameActive
        case editAction
         
        var nameString:String {
            switch self {
            case .appBecameActive:
                return "app_became_active"
            case .editAction:
                return "edit_action"
            }
        }
        
        var name:NSNotification.Name {
            return NSNotification.Name(rawValue: nameString)
        }
    }
    
    enum Regex {
        static let validIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
        static let validHostnameRegex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$"
        static let ipFetchRegex = #"((\d+)\.(\d+)\.(\d+)\.(\d+))"#
    }

}

extension UserDefaults {
    static var  group:UserDefaults? {
        return UserDefaults(suiteName: Constants.appGroupIdentifier)
    }
}

func dispatchAfter(delay:Double, task:@escaping ()->Void) {
    
    let delay = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    
    DispatchQueue.main.asyncAfter(deadline: delay) {
        task()
    }
}

