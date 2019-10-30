//
//  KeychainWrapper.swift
//  WHCoreServices
//
//  Created by Hsiao, Wayne on 2019/9/27.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import Foundation
import Security

public typealias KeychainWrapperAdoptor = KeychainItemQueryable & KeychainItemStorable

public struct KeychainWrapper {
    
    var queryable: KeychainWrapperAdoptor

    public init(queryable: KeychainWrapperAdoptor) {
        self.queryable = queryable
    }

    public func setRef(_ data: Data,
                       forAccount account: String,
                       isHighSecured: Bool = true) throws {
        do {
            guard let cert = SecCertificateCreateWithData(nil, data as CFData) else {
                throw WrapperError.stringToDataError
            }

            let updateValue = [kSecValueRef.toString: cert]
            try addOrUpdate(data,
                            forAccount: account,
                            isHighSecured: isHighSecured,
                            updateData: updateValue)
            
        } catch {
            throw error
        }
    }

    /// Set value
    /// - Parameter value: Value like to be stored into keychain.
    /// - Parameter account: Used to identifier the item.
    /// - Parameter isHighSecured: Whether enable ACL and keychain entries protection.
    /// */
    public func setValue(_ value: String,
                         forAccount account: String,
                         isHighSecured: Bool = true,
                         isForceAdd: Bool = true) throws {
        
        do {
            guard let encodedData = value.data(using: .utf8) else {
                throw WrapperError.stringToDataError
            }

            var attributesToUpdate = [String: Any]()
            attributesToUpdate[kSecValueData.toString] = encodedData
            if isForceAdd == true {
                try forceAdd(value,
                             forAccount: account,
                             isHighSecured: true)
            } else {
                try addOrUpdate(value,
                                forAccount: account,
                                isHighSecured: true,
                                updateData: attributesToUpdate)
            }
        } catch {
            throw error
        }
    }
    
    /// Add new value for account no matter if here is existing data.
    /// - Parameter data: Data would be stored into keychain.
    /// - Parameter account: Store data for account.
    /// - Parameter isHighSecured: Whether enable ACL and keychain entries protection.
    fileprivate func forceAdd(_ data: Any,
                              forAccount account: String,
                              isHighSecured: Bool) throws {
        let addquery = try queryable.addquery(data, account: account, isHighSecured: isHighSecured)
        let addstatus = SecItemAdd(addquery.toCFDictionary, nil)
        
        if addstatus == errSecDuplicateItem {
            do {
                try removeValue(for: account)
            } catch {
                throw WrapperError.error(from: addstatus)
            }
            let addstatus = SecItemAdd(addquery.toCFDictionary, nil)
            
            if addstatus != errSecSuccess {
                throw WrapperError.error(from: addstatus)
            }
        } else if addstatus != errSecSuccess {
            throw WrapperError.error(from: addstatus)
        }
    }

    /// Add value to accout, update value if here is existing value.
    /// - Parameter data: Data would be stored into keychain.
    /// - Parameter account: Store data for account.
    /// - Parameter isHighSecured: Whether enable ACL and keychain entries protection.
    /// - Parameter updateData: Data to updated to the existing value.
    fileprivate func addOrUpdate(_ data: Any,
                                 forAccount account: String,
                                 isHighSecured: Bool = true,
                                 updateData: [String: Any]) throws {

        let addquery = try queryable.addquery(data, account: account, isHighSecured: isHighSecured)
        let addstatus = SecItemAdd(addquery.toCFDictionary, nil)
        
        if addstatus == errSecDuplicateItem {
            let addstatus = SecItemUpdate(addquery.toCFDictionary,
                                          updateData.toCFDictionary)
            
            if addstatus != errSecSuccess {
                throw WrapperError.error(from: addstatus)
            }
        } else if addstatus != errSecSuccess {
            throw WrapperError.error(from: addstatus)
        }
    }

    /// Get value reference.
    /// - Parameter account: Identify the value of the specific account.
    public func getRef(for account: String) throws -> Data? {
        var query = queryable.getquery
        query[kSecMatchLimit.toString] = kSecMatchLimitOne
        query[kSecReturnAttributes.toString] = kCFBooleanTrue
        query[kSecAttrLabel.toString] = account
        query[kSecReturnRef.toString] = kCFBooleanTrue

        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query.toCFDictionary, $0)
        }

        switch status {
        case errSecSuccess:
            guard let queriedItem = queryResult as? [AnyHashable: SecCertificate],
                let certificate = queriedItem[kSecValueRef.toString] else {
                    throw WrapperError.dataToStringError
            }
            return SecCertificateCopyData(certificate) as Data
        case errSecItemNotFound:
            return nil
        default:
            throw WrapperError.error(from: status)
        }
    }

    /// Retrieve value of specific account from keychain
    /// - Parameter account: Name of the account.
    public func getValue(for account: String) throws -> String? {
        var query = queryable.getquery
        query[kSecMatchLimit.toString] = kSecMatchLimitOne
        query[kSecReturnAttributes.toString] = kCFBooleanTrue
        query[kSecReturnData.toString] = kCFBooleanTrue
        query[kSecAttrAccount.toString] = account
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query.toCFDictionary, $0)
        }

        switch status {
        case errSecSuccess:
            guard let queriedItem = queryResult as? [String: Any],
                let data = queriedItem[kSecValueData.toString] as? Data,
                let password = String(data: data, encoding: .utf8) else {
                    throw WrapperError.dataToStringError
            }
            return password
        case errSecItemNotFound:
            return nil
        default:
            throw WrapperError.error(from: status)
        }
    }

    /// Remove items which stored value of specific account.
    /// - Parameter account: Name of the account.
    public func removeValue(for account: String) throws {
        var query = queryable.getquery
        query[kSecAttrAccount.toString] = account

        let status = SecItemDelete(query.toCFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw WrapperError.error(from: status)
        }
    }

    /// Remove items which stored reference for specific account.
    /// - Parameter account: Name of the account.
    public func removeRef(for account: String) throws {
        var query = queryable.getquery
        query[kSecAttrLabel.toString] = account

        let status = SecItemDelete(query.toCFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw WrapperError.error(from: status)
        }
    }

    /// Clear all items in the keychain.
    public func removeAll() throws {
        let status = SecItemDelete(queryable.getquery.toCFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw WrapperError.error(from: status)
        }
    }

    public func setData(_ data: Data,
                        forAccount account: String,
                        isHighSecured: Bool = true) throws {
        do {
            var attributesToUpdate = [String: Any]()
            attributesToUpdate[kSecValueData.toString] = data
            try addOrUpdate(data,
                            forAccount: account,
                            isHighSecured: isHighSecured,
                            updateData: attributesToUpdate)

        } catch {
            throw error
        }
    }

    public func getData(for account: String) throws -> Data? {
        var query = queryable.getquery
        query[kSecMatchLimit.toString] = kSecMatchLimitOne
        query[kSecReturnData.toString] = kCFBooleanTrue
        query[kSecAttrAccount.toString] = account

        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query.toCFDictionary, $0)
        }

        switch status {
        case errSecSuccess:
            guard let data = queryResult as? Data else {
                    throw WrapperError.convertError
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw WrapperError.error(from: status)
        }
    }
}
