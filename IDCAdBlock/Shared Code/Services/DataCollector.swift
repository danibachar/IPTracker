//
//  DataCollector.swift
//  IPTracker
//
//  Created by Daniel Bachar on 07/02/2020.
//  Copyright © 2020 IDC. All rights reserved.
//

import Foundation

final class DataCollector {
    //Singleton
    static let instance = DataCollector()
    // Services
    private lazy var ipFetcher = IPFetcher()
    private lazy var ipReported = IPReporter()
    private lazy var connectionNotifier = InternetConnectionTypeNotifier()
    private lazy var formater: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return f
    }()
    // Cache
    private var lastCollectedConnectionType: String = ""
    private var lastCollectedIps: [String] = []
    // State
    private var isCollecting: Bool = false {
        didSet {
            loading?(isCollecting)
        }
    }
    private var isNotifying: Bool = false {
        didSet {
            loading?(isNotifying)
        }
    }
    private lazy var stopRecursion: Bool = false
    // Collection State
    private let lastCollectionDateKey = "lastCollectionDate"
    private var lastCollectionDate: Date {
        get {
            guard
                let dateString = UserDefaults.standard.string(forKey: lastCollectionDateKey),
                let lastDate = formater.date(from: dateString)
            else {
                let newDate = Date()
                UserDefaults.standard.set(formater.string(from: newDate), forKey: lastCollectionDateKey)
                return newDate
            }
            return lastDate
        }
        set {
            UserDefaults.standard.set(formater.string(from: Date()), forKey: lastCollectionDateKey)
        }

    }
    // Notificaiton State
    private let lastNotificationDateKey = "lastNotificationDate"
    private var lastNotificationDate: Date {
        get {
            guard
                let dateString = UserDefaults.standard.string(forKey: lastNotificationDateKey),
                let lastDate = formater.date(from: dateString)
            else {
                let newDate = Date()
                UserDefaults.standard.set(formater.string(from: newDate), forKey: lastNotificationDateKey)
                return newDate
            }
            return lastDate
        }
        set {
            UserDefaults.standard.set(formater.string(from: Date()), forKey: lastNotificationDateKey)
        }

    }
    
    
    // Delegates
    var ipsUpdates: ((_ ips: [String]) -> Void)?
    var connectionUpdates: ((_ connection: String) -> Void)?
    var loading: ((_ isLoading: Bool) -> Void)?
    
    init() {
        connectionNotifier.connectionUpdates = { [weak self] status in
            // Fill Cache
            self?.lastCollectedConnectionType = status
            // Notify Delegate on new state
            self?.connectionUpdates?(status)
            // Force new collection and notification
            print("connectionUpdates")
            self?.updateLogic(false, true)
        }
    }
    // MARK: - Public
    private var recurseCount: Int = 0
    func startCollecting() {
        stopRecursion=false
        print("startCollecting")
        updateLogic(recurseCount<1)
        recurseCount+=1
    }
    
    func stopCollecting() {
        stopRecursion=true
    }
    // MARK: - Private
    // MARK: - Actions
    
    func updateLogic(_ shouldRecurse: Bool, _ forceCollection: Bool=false) {
        print("### updateLogic 1")
        guard !stopRecursion, !isCollecting, !isNotifying else { return }
        
        if forceCollection {
            collectData { [ weak self] (didIpChanged) in
                guard didIpChanged else { return }
                self?.notifyNewData(completion: { (didNotify) in
                    guard shouldRecurse else { return }
                    self?.recurse()
                })
            }
            return
        }
        
        
        
        print("### updateLogic 2")
        let timePassedFromLastNotification = -(lastNotificationDate.timeIntervalSinceNow) >= Constants.notificationTimeInterval
        let didNverCollect = lastCollectedIps.isEmpty
        if timePassedFromLastNotification || didNverCollect {
            print("### updateLogic 3")
            collectData { [weak self] (didIpChanged) in
                guard didIpChanged else {
                    guard shouldRecurse else { return }
                    self?.recurse()
                    return
                }
                print("### updateLogic 4")
                self?.notifyNewData { (didNotify) in
                    print("### updateLogic 5")
                    guard shouldRecurse else { return }
                    self?.recurse()
                }
            }
        } else {
            let timePassedFromLastCollection = -(lastCollectionDate.timeIntervalSinceNow) >= Constants.collectionTimeInterval
            if timePassedFromLastCollection {
                print("### updateLogic 7")
                collectData { [weak self] (didIpChanged) in
                    guard didIpChanged else {
                        guard shouldRecurse else { return }
                        self?.recurse()
                        return
                    }
                    print("### updateLogic 8")
                    self?.notifyNewData(completion: { (diNotify) in
                        guard shouldRecurse else { return }
                        self?.recurse()
                    })
                }
            } else {
                guard shouldRecurse else { return }
                self.recurse()
            }
        }
    }
    
    // MARK: - Sub Actions
    private func recurse() {
        print("recurse called")
        let interval = Constants.collectionTimeInterval
        DispatchQueue.main.asyncAfter(deadline: .now()+interval) { [weak self] in
            guard let self = self, !self.stopRecursion else { return }
            print("recursing")
            self.updateLogic(true)
        }
    }
    private func collectData(completion: ((Bool) -> Void)?=nil) {
        guard !isCollecting else {
            completion?(false)
            return
        }
        isCollecting = true
        ipFetcher.collect { [weak self] (ips) in
            // State
            self?.isCollecting = false
            self?.lastCollectionDate = Date()
            
            let collectedIps = Array(ips ?? [])
            let lastCollectedIps = self?.lastCollectedIps ?? []
            
            self?.lastCollectedIps = collectedIps
            //Delegatet
            self?.ipsUpdates?(collectedIps)
            
            let didIpChangedFromLastCollection = Set<String>(lastCollectedIps) != Set<String>(collectedIps)
            completion?(didIpChangedFromLastCollection)
        }
    }
    
    private func notifyNewData(completion: ((Bool) -> Void)?=nil) {
        guard !isNotifying else {
            completion?(false)
            return
        }
        isNotifying = true
        ipReported.send(ips: lastCollectedIps, connectionTypeName: lastCollectedConnectionType) { [ weak self] error in
            self?.isNotifying = false
            self?.lastNotificationDate = Date()
            completion?(true)
        }
    }
}


