//
//  FilterDataProvider.swift
//  SiftData
//
//  Created by Alex Grinman on 12/23/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import NetworkExtension

class FilterDataProvider: NEFilterDataProvider {

    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // Add code to initialize the filter.
        DataCollector.instance.startCollecting()
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources.
        DataCollector.instance.startCollecting()
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        DataCollector.instance.startCollecting()
        return .allow()
    }
}
