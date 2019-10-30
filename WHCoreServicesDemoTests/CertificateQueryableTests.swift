//
//  CertificateQueryableTests.swift
//  WHCoreServicesDemoTests
//
//  Created by Hsiao, Wayne on 2019/9/29.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import XCTest
@testable import WHCoreServicesDemo
@testable import WHCoreServices

class CertificateQueryableTests: XCTestCase {

    let genericPassword = CertificateQueryable()
    lazy var keychainWrapper: KeychainWrapper = {
        return KeychainWrapper(queryable: genericPassword)
    }()
    
    let cert: Data = {
        let bundle = Bundle(identifier: "com.wayne.hsiao.WHCoreServicesDemoTests")
        guard let path = bundle?.path(forResource: "certificate", ofType: "der") else {
            XCTFail("Saving value failed.")
            return Data()
        }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else {
            XCTFail("Saving value failed.")
            return Data()
        }
        return data
    }()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        try? keychainWrapper.removeAll()
    }

    func testRemoveForAccount() {
        do {
            try keychainWrapper.setRef(cert,
                                         forAccount: Constant.account)
            try keychainWrapper.removeRef(for: Constant.account)
            XCTAssertNil(try keychainWrapper.getRef(for: Constant.account))
        } catch {
            XCTFail("Saving value failed. - \(error.localizedDescription)")
        }
    }
    
    func testRemoveAll() {
        do {
            try keychainWrapper.setRef(cert, forAccount: Constant.account2)
            try keychainWrapper.removeAll()
            XCTAssertNil(try keychainWrapper.getRef(for: Constant.account2))
        } catch {
            XCTFail("Saving value failed. - \(error.localizedDescription)")
        }
    }
    
    func testSetGetRef() {
        do {
            try keychainWrapper.setRef(cert, forAccount: Constant.account)
            XCTAssertEqual(try keychainWrapper.getRef(for: Constant.account), cert)
        } catch {
            XCTFail("Saving value failed. - \(error.localizedDescription)")
        }
    }

}
