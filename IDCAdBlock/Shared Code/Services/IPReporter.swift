//
//  DataSender.swift
//  IPTracker
//
//  Created by Daniel Bachar on 07/02/2020.
//  Copyright © 2020 IDC. All rights reserved.
//

import Foundation
import UIKit
import Moya
import Alamofire

final class IPReporter {
    private lazy var apiProvider: MoyaProvider<ServerAPI> = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "34.66.13.230": .disableEvaluation
        ]
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return MoyaProvider<ServerAPI>(manager: manager, plugins: [NetworkLoggerPlugin(verbose: true)])
    }()
    
    private lazy var encoder = JSONEncoder()
    
    func send(ips: Set<String>?, completion: ((_ error: Error?) -> Void)?) {
        guard let ips = ips else {
            completion?(NSError(domain: "Missing IPs", code: 1, userInfo: nil))
            return
        }
        
        let string = "\(Constants.deviceIdentifier)|\(ips.joined(separator: ","))"
        guard let data = try? JSONEncoder().encode(string) else {
            completion?(NSError(domain: "Faild Converting String to data", code: 2, userInfo: nil))
            return
        }
        apiProvider.request(.updateCollection(base64: data.base64EncodedString())) { (res) in
            switch res {
            case .failure(let error):
                completion?(error)
            case .success(_):
                completion?(nil)
            }
            
        }
    }
}
