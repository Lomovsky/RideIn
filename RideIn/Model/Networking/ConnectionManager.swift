//
//  ConnectionManager.swift
//  RideIn
//
//  Created by Алекс Ломовской on 24.04.2021.
//

import SystemConfiguration

protocol ReachabilityCheckable {
  static func isConnectedToNetwork() -> Bool
}

//MARK:- ConnectionManager
final public class ConnectionManager: ReachabilityCheckable {
  static func isConnectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in(
      sin_len: 0,
      sin_family: 0,
      sin_port: 0,
      sin_addr: in_addr(s_addr: 0),
      sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
        SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
      }
    }
    
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
      return false
    }
    
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    let ret = (isReachable && !needsConnection)
    
    return ret
  }
  
  deinit {
    Log.i("deallocating \(self)")
  }
}
