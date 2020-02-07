//
//  ServerAPI.swift
//  IPTracker
//
//  Created by Daniel Bachar on 07/02/2020.
//  Copyright © 2020 IDC. All rights reserved.
//

import Foundation
import Moya
//        https://34.66.13.230/iostatistics.php?info=<BASED64_INFO>

enum ServerAPI {
    case updateCollection(base64: String)
}

extension ServerAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://34.66.13.230")!
    }
    
    var path: String {
        return "iostatistics.php"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch  self {
        case .updateCollection(let base64):
            return .requestParameters(parameters: ["info": base64], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
