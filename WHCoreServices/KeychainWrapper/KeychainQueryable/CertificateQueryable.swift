//
//  CertificateQueryable.swift
//  WHCoreServices
//
//  Created by Hsiao, Wayne on 2019/9/29.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import Foundation

// swiftlint:disable all
/// Keychain wrapper for item class [kSecClassCertificate](https://developer.apple.com/documentation/security/ksecclasscertificate).
/// You can check example in the [Apple documentation](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/certificates/storing_a_certificate_in_the_keychain).
// swiftlint:enable all
public struct CertificateQueryable {
    let accessGroup: String?

    public init(accessGroup: String? = nil) {
        self.accessGroup = accessGroup
    }
}

extension CertificateQueryable: KeychainItemQueryable {
    public var getquery: [String: Any] {
        var query = [
            kSecClass.toString: kSecClassCertificate,
            kSecReturnRef.toString: kCFBooleanTrue as Any] as [String: Any]
        
        #if !targetEnvironment(simulator)
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup.toString] = accessGroup
        }
        #endif
        return query
    }
}

extension CertificateQueryable: KeychainItemStorable {
    public func addquery(_ value: Any,
                         account: String,
                         isHighSecured: Bool) throws -> [String: Any] {
        guard let data = value as? Data,
            let cert = SecCertificateCreateWithData(nil, data as CFData) else {
                throw WrapperError.certificateGenerateError
        }
        
        var query =
            [
                kSecClass.toString: kSecClassCertificate,
                kSecValueRef.toString: cert,
                kSecAttrLabel.toString: account] as [String: Any]
        
        #if !targetEnvironment(simulator)
        if isHighSecured == true {
            query[kSecAttrAccessControl.toString] = accessControl()
        }
        #endif
        
        return query
    }
}
