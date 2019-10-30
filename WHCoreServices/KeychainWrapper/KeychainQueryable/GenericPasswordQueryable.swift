//
//  GenericPasswordQueryable.swift
//  WHCoreServices
//
//  Created by Hsiao, Wayne on 2019/9/29.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import Foundation
import LocalAuthentication

// swiftlint:disable all
/// Keychain wrapper for item class [kSecClassGenericPassword](https://developer.apple.com/documentation/security/ksecclassgenericpassword)
// swiftlint:enable all
public struct GenericPasswordQueryable {
    let service: String
    let accessGroup: String?
    
    public init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
}

extension GenericPasswordQueryable: KeychainItemQueryable {
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

extension GenericPasswordQueryable: KeychainItemStorable {
    public func addquery(_ value: Any,
                         account: String,
                         isHighSecured: Bool = true) throws -> [String: Any] {
        guard let stringValue = value as? String,
            let encodedData = stringValue.data(using: .utf8) else {
                throw WrapperError.stringToDataError
        }

        var query = getquery
        #if !targetEnvironment(simulator)
        if isHighSecured == true {
            query[kSecAttrAccessControl.toString] = accessControl()
        }
        #endif
        query[kSecAttrAccount.toString] = account
        query[kSecValueData.toString] = encodedData
        return query
    }
}
