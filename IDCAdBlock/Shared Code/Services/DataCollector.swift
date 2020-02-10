//
//  DataCollector.swift
//  IPTracker
//
//  Created by Daniel Bachar on 07/02/2020.
//  Copyright © 2020 IDC. All rights reserved.
//

import Foundation

final class DataCollector {
    static let instance = DataCollector()
    
    private lazy var ipFetcher = IPFetcher()
    private lazy var ipReported = IPReporter()
    private lazy var isCollecting: Bool = false
    private lazy var shouldCollect: Bool = false
    
    var ipsUpdates: ((_ ips: [String]) -> Void)?
    
    func startCollecting() {
        shouldCollect = true
        collectAndReport()
    }
    
    func stopCollecting() {
        shouldCollect = false
    }
    
    @objc private 
    func collectAndReport() {
        // Only if not running collection process, and if allowed to collect
        guard shouldCollect,!isCollecting else { return }
        isCollecting = true
        ipFetcher.collect { [weak self] (ips) in
            self?.ipsUpdates?(Array(ips ?? []))
            self?.ipReported.send(ips: ips) { [ weak self] error in
                self?.isCollecting = false
                let interval = Constants.collectionTimeInterval
                DispatchQueue.main.asyncAfter(deadline: .now()+interval) {
                    guard let self = self, self.shouldCollect else { return }
                    self.collectAndReport()
                }
            }
        }
    }
}
