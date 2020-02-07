//
//  DataCollector.swift
//  IPTracker
//
//  Created by Daniel Bachar on 07/02/2020.
//  Copyright © 2020 IDC. All rights reserved.
//

import Foundation

final class DataCollector {
    private lazy var ipFetcher = IPFetcher()
    private lazy var ipReported = IPReporter()
    
    private lazy var timer = Timer.scheduledTimer(
        timeInterval: 30.0,
        target: self, selector:
        #selector(collectAndReport),
        userInfo: nil,
        repeats: true
    )
    private var isCollecting: Bool = false
    
    func startCollecting() {
        collectAndReport()
    }
    
    
    @objc private 
    func collectAndReport() {
        guard !isCollecting else { return }
        isCollecting = true
        ipFetcher.collect { [weak self] (ips) in
            self?.ipReported.send(ips: ips) { [ weak self] error in
                self?.isCollecting = false
                print("Done")
                DispatchQueue.main.asyncAfter(deadline: .now()+1000.0) {
                    self?.collectAndReport()
                }
            }
        }
    }
}
