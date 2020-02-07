//
//  IPCollector.swift
//  IPTracker
//
//  Created by Daniel Bachar on 07/02/2020.
//  Copyright © 2020 IDC. All rights reserved.
//

import Foundation
import Moya

typealias IPCollectorDecoder = ( (_ data: Data) -> String? )?

enum IPCollector {
    case ip(address: String, decoder: IPCollectorDecoder )
}
extension IPCollector {
    var decoder: IPCollectorDecoder {
        switch self {
        case .ip(let tuple):
            return tuple.decoder
        }
    }
    
    var myHash: String {
        switch self {
        case .ip(let tuple):
            return tuple.address
        }
    }
}
extension IPCollector: Hashable {
    static func == (lhs: IPCollector, rhs: IPCollector) -> Bool {
        return lhs.myHash == rhs.myHash
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(myHash)
    }
    
}

extension IPCollector: TargetType {
    var baseURL: URL {
        switch self {
        case .ip(let tuple):
            return URL(string: tuple.address)!
        }
    }
    var path: String {
        return ""
    }
    var method: Moya.Method {
        return .get
    }
    var sampleData: Data {
        return Data()
    }
    var task: Task {
        return .requestPlain
    }
    var headers: [String : String]? {
        return nil
    }
}
