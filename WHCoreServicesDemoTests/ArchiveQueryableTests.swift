//
//  ArchiveQueryableTests.swift
//  WHCoreServicesDemoTests
//
//  Created by Hsiao, Wayne on 2019/10/5.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import XCTest
@testable import WHCoreServicesDemo
@testable import WHCoreServices

class ArchiveQueryableTests: XCTestCase {
    
    let archive = ArchiveQueryable(service: "test")
    
    lazy var keychainWrapper: KeychainWrapper = {
        return KeychainWrapper(queryable: archive)
    }()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        try? keychainWrapper.removeAll()
    }
    
    func testSetArchived() {
        let someString = "123"
        do {
            let archived = try NSKeyedArchiver.archivedData(withRootObject: someString, requiringSecureCoding: true)
            try keychainWrapper.setData(archived, forAccount: "generate")
        } catch {
            XCTFail("TestSetArchived value failed. - \(error.localizedDescription)")
        }
    }
    
    func testGetArchived() {
        let account = "generate"
        let someString = "123"
        do {
            let archived = try NSKeyedArchiver.archivedData(withRootObject: someString, requiringSecureCoding: true)
            try keychainWrapper.setData(archived, forAccount: account)
            guard let data = try keychainWrapper.getData(for: account),
                let unArchived = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? String else {
                    XCTFail("testGetArchived failed")
                    return
            }
            XCTAssertEqual(unArchived, someString)
        } catch {
            XCTFail("TestGetArchived value failed. - \(error.localizedDescription)")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
