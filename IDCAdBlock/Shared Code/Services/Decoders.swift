//
//  Decoders.swift
//  IPTracker
//
//  Created by Daniel Bachar on 07/02/2020.
//  Copyright © 2020 IDC. All rights reserved.
//

import Foundation

func stringDecoder(_ data: Data) -> String? {
    return String(data: data, encoding: .utf8)
}

func htmlStringDecoder(_ data: Data) -> String? {
    guard
        let string = stringDecoder(data),
        let range = string.range(of: Constants.Regex.ipFetchRegex, options: .regularExpression)
    else { return nil}
    return String(string[range])
}

func jsonDecoder(_ data: Data) -> String? {
    do {
        let json = try JSONDecoder.module.decode(JSONValue.self, from: data)
        return json.stringValue(for: "ip")
    } catch {
        print(error)
        return nil
    }
    
}

private extension JSONDecoder {
    static let module = JSONDecoder()
}
