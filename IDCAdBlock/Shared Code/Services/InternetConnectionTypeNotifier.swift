//
//  InternetConnectionTypeNotifier.swift
//  IDCAdBlock
//
//  Created by Daniel Bachar on 10/02/2020.
//  Copyright © 2020 Alex Grinman. All rights reserved.
//

import Foundation
import Alamofire

final class InternetConnectionTypeNotifier {
    private lazy var manager = NetworkReachabilityManager(host: "www.apple.com")
    var connectionUpdates: ((String) -> Void)?
    init() {
        manager?.listener = { [weak self] status in
            self?.connectionUpdates?(status.name)
        }
        manager?.startListening()
    }

}

private extension NetworkReachabilityManager.NetworkReachabilityStatus {
    var name: String {
        switch self {
        case .reachable(let type):
            return type.name
        case .notReachable:
            return "notReachable"
        case .unknown:
            return "unknown"
        }
    }
}
private extension NetworkReachabilityManager.ConnectionType {
    var name: String {
        switch self {
        case .ethernetOrWiFi:
            return "ethernetOrWiFi"
        case .wwan:
            return "wwan"
        }
    }
}
