//
//  KeychainQueryable.swift
//  WHCoreServices
//
//  Created by Hsiao, Wayne on 2019/9/27.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import Foundation
import Security

public enum WrapperError: Error {
    case stringToDataError
    case dataToStringError
    case convertError
    case notFound
    case failed
    case certificateGenerateError
    case unknowError(message: String)
    
    static public func error(from status: OSStatus) -> WrapperError {
        if #available(iOS 11.3, *) {
            guard let message = SecCopyErrorMessageString(status, nil) else {
                    return WrapperError.unknowError(message: "Unknow error")
            }
            return WrapperError.unknowError(message: message as String)
        } else {
            return WrapperError.unknowError(message: "Unknow error")
        }
    }
}

/// Keychain queryable protocol which referenced by KeychainWrapper.
public protocol KeychainItemQueryable {
    var getquery: [String: Any] { get }
}

public protocol KeychainItemStorable {
    func addquery(_ value: Any,
                  account: String,
                  isHighSecured: Bool) throws -> [String: Any]
}

extension KeychainItemStorable {
    func accessControl() -> SecAccessControl? {
        var error: Unmanaged<CFError>?
        let access = SecAccessControlCreateWithFlags(nil,
                                                     kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                     .userPresence, &error)
        precondition(access != nil, "SecAccessControlCreateWithFlags failed")
        return access
    }
}
