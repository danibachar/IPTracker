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
    private lazy var connectionNotifier = InternetConnectionTypeNotifier()
    // Delegates
    var ipsUpdates: ((_ ips: [String]) -> Void)?
    var connectionUpdates: ((_ connection: String) -> Void)?
    private var connectionTypCache: String = ""
    
    init() {
        connectionNotifier.connectionUpdates = { [weak self] status in
            // Notifty delegate and run stop/start collection
            self?.connectionTypCache = status
            self?.connectionUpdates?(status)
            self?.forceOneTimeCollection()
            self?.startCollecting()
        }
    }
    
    func startCollecting() {
        shouldCollect = true
        collectAndReportRecursivley()
    }
    
    func stopCollecting() {
        shouldCollect = false
    }
    
    func forceOneTimeCollection() {
        ipFetcher.collect { [weak self] (ips) in
            self?.ipsUpdates?(Array(ips ?? []))
            self?.ipReported.send(ips: ips, connectionTypeName: self?.connectionTypCache ,completion: nil)
        }
    }
    
    private func collectAndReportRecursivley() {
        // Only if not running collection process, and if allowed to collect
        guard shouldCollect,!isCollecting else { return }
        isCollecting = true
        ipFetcher.collect { [weak self] (ips) in
            self?.ipsUpdates?(Array(ips ?? []))
            self?.ipReported.send(ips: ips, connectionTypeName: self?.connectionTypCache) { [ weak self] error in
                self?.isCollecting = false
                let interval = Constants.collectionTimeInterval
                DispatchQueue.main.asyncAfter(deadline: .now()+interval) {
                    guard let self = self, self.shouldCollect else { return }
                    self.collectAndReportRecursivley()
                }
            }
        }
    }
}


