//
//  DataCollector.swift
//  IPTracker
//
//  Created by Daniel Bachar on 07/02/2020.
//  Copyright © 2020 IDC. All rights reserved.
//

import Foundation
import Moya

final class IPFetcher {
    private lazy var collectionProvider = MoyaProvider<IPCollector>()
    private lazy var collectors: [IPCollector] = {
        return [
            IPCollector.ip(address: "https://www.myexternalip.com/raw", decoder: stringDecoder),
            IPCollector.ip(address: "https://api.myip.com", decoder: jsonDecoder),
            IPCollector.ip(address: "https://ipv4bot.whatismyipaddress.com", decoder: stringDecoder),
            IPCollector.ip(address: "https://ipinfo.io/json", decoder: jsonDecoder),
            IPCollector.ip(address: "https://api.ipify.org/", decoder: stringDecoder),
            IPCollector.ip(address: "https://www.nirsoft.net/show_my_ip_address.php", decoder: htmlStringDecoder),
            ]
    }()
    private lazy var results = [IPCollector: String]()
    private lazy var queue = DispatchQueue(label: "collection.queue")
    init() {
        
    }
    private func pCollect(completion: ( (_ ips: Set<String>?) -> Void)?) {
        let group = DispatchGroup()
        let smaphore = DispatchSemaphore(value: 1)
        collectors.forEach { _ in group.enter() }
        collectors.forEach {[weak self] (collector) in
            smaphore.wait()
            self?.collectionProvider.request(collector) { (res) in
                switch res {
                case .failure(let error):
                    print(error)
                case .success(let res):
                    self?.results[collector] = collector.decoder?(res.data)
                }
                smaphore.signal()
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let ips = self?.results.values else {
                completion?(nil)
                return
            }
            
            let validAddressed = ips.filter(validIp)
            self?.results.removeAll()
            completion?(Set<String>(validAddressed))
        }
    }
    func collect(completion: ( (_ ips: Set<String>?) -> Void)?) {
        queue.async { [weak self] in
            self?.pCollect(completion: completion)
        }

    }
}


