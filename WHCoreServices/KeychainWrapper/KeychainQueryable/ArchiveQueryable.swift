//
//  ArchiveQueryable.swift
//  WHCoreServices
//
//  Created by Hsiao, Wayne on 2019/10/5.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import Foundation

public struct ArchiveQueryable {
    let service: String
    let accessGroup: String?
    
    public init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
}

extension ArchiveQueryable: KeychainItemQueryable {
    public var getquery: [String: Any] {
        var query = [
            kSecClass.toString: kSecClassGenericPassword,
            kSecAttrService.toString: service
            ] as [String: Any]
        
        #if !targetEnvironment(simulator)
        if let accessGroup = accessGroup {
          query[String(kSecAttrAccessGroup)] = accessGroup
        }
        #endif
        return query
    }
}

extension ArchiveQueryable: KeychainItemStorable {
    public func addquery(_ value: Any,
                         account: String,
                         isHighSecured: Bool) throws -> [String: Any] {
        guard let data = value as? Data else {
            throw WrapperError.stringToDataError
        }
        var query = getquery
        query[kSecAttrAccount.toString] = account
        query[kSecValueData.toString] = data
        #if !targetEnvironment(simulator)
        if isHighSecured == true {
            query[kSecAttrAccessControl.toString] = accessControl()
        }
        #endif
        return query
    }
}
