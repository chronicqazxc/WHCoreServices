//
//  InternetPasswordQueryable.swift
//  WHCoreServices
//
//  Created by Hsiao, Wayne on 2019/9/29.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import Foundation

// swiftlint:disable all
/// Keychain wrapper for item class [kSecClassInternetPassword](https://developer.apple.com/documentation/security/ksecclassinternetpassword)
// swiftlint:enable all
public struct InternetPasswordQueryable {
    let server: String
    let port: Int
    let path: String
    let securityDomain: String
    let internetProtocol: String
    let internetAuthenticationType: String
    let accessGroup: String?
    
    public init(server: String,
                port: Int,
                path: String,
                securityDomain: String,
                internetProtocol: String,
                internetAuthenticationType: String,
                accessGroup: String? = nil) {
        self.server = server
        self.port = port
        self.path = path
        self.securityDomain = securityDomain
        self.internetProtocol = internetProtocol
        self.internetAuthenticationType = internetAuthenticationType
        self.accessGroup = accessGroup
    }
}

extension InternetPasswordQueryable: KeychainItemQueryable {
    public var getquery: [String: Any] {
        var query = [
            kSecClass.toString: kSecClassInternetPassword,
            kSecAttrPort.toString: port,
            kSecAttrServer.toString: server,
            kSecAttrSecurityDomain.toString: securityDomain,
            kSecAttrPath.toString: path,
            kSecAttrProtocol.toString: internetProtocol,
            kSecAttrAuthenticationType.toString: internetAuthenticationType
            ] as [String: Any]

        #if !targetEnvironment(simulator)
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup.toString] = accessGroup
        }
        #endif
        return query
    }
}

extension InternetPasswordQueryable: KeychainItemStorable {
    public func addquery(_ value: Any,
                         account: String,
                         isHighSecured: Bool) throws -> [String: Any] {
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
