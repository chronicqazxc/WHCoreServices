//
//  GenericPasswordQueryableTests.swift
//  GenericPasswordQueryableTests
//
//  Created by Hsiao, Wayne on 2019/9/27.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import XCTest
@testable import WHCoreServicesDemo
@testable import WHCoreServices

class GenericPasswordQueryableTests: XCTestCase {

    let genericPassword = GenericPasswordQueryable(service: "test")
    lazy var keychainWrapper: KeychainWrapper = {
        return KeychainWrapper(queryable: genericPassword)
    }()

    let internetPassword = InternetPasswordQueryable(server: "com.wayne.hsiao",
                                                     port: 8080,
                                                     path: "url/path",
                                                     securityDomain: "domain",
                                                     internetProtocol: kSecAttrProtocolHTTPS.toString,
                                                     internetAuthenticationType:
        kSecAttrAuthenticationTypeHTTPBasic.toString)

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        try? keychainWrapper.removeAll()
    }
    
    func testRemoveForAccount() {
        do {
            let password = "123"
            try keychainWrapper.setValue(password,
                                         forAccount: Constant.account)
            try keychainWrapper.removeValue(for: Constant.account)
            XCTAssertNil(try keychainWrapper.getValue(for: Constant.account))
        } catch {
            XCTFail("Saving value failed. - \(error.localizedDescription)")
        }
    }

    func testRemoveAll() {
        do {
            try keychainWrapper.setValue("123",
                                         
                                         forAccount: Constant.account)
            try keychainWrapper.setValue("123",
            
            forAccount: Constant.account2)
            try keychainWrapper.removeAll()
            XCTAssertNil(try keychainWrapper.getValue(for: Constant.account))
            XCTAssertNil(try keychainWrapper.getValue(for: Constant.account2))
        } catch {
            XCTFail("Saving value failed. - \(error.localizedDescription)")
        }
    }

    func testGetValue() {
        do {
            let password = "123"
            // Test add new value.
            try keychainWrapper.setValue(password,
                                         forAccount: Constant.account)
//            // Test update old value.
//            try keychainWrapper.setValue(password,
//            forAccount: Constant.account)

            XCTAssertEqual(try keychainWrapper.getValue(for: Constant.account), password)
        } catch {
            XCTFail("Saving value failed. - \(error.localizedDescription)")
        }
    }

    func testSetValue() {
        do {
            try keychainWrapper.setValue("123",
                                        forAccount: "generate")
        } catch {
            XCTFail("Saving value failed. - \(error.localizedDescription)")
        }

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
