//
//  Helpers.swift
//  IDCAdBlock
//
//  Created by Daniel Bachar on 10/02/2020.
//  Copyright © 2020 Alex Grinman. All rights reserved.
//

import Foundation
func validIp(_ ip: String) -> Bool {
    let isNotValid = ip.range(
        of: Constants.Regex.validIpAddressRegex,
        options: .regularExpression,
        range: nil,
        locale: nil
    )?.isEmpty ?? true
    return !isNotValid
}
