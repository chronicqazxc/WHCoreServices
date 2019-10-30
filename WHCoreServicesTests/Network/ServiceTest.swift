//
//  ServicesTest.swift
//  WHCoreServicesTests
//
//  Created by Wayne Hsiao on 2019/4/5.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import XCTest
@testable import WHCoreServices

class ServicesTest: XCTestCase {

    let session = MockURLSession()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPlistParser() {
        let mockBundle = Bundle(identifier: "com.wayne.WHCoreServicesTests")!
        XCTAssertNotNil(Service.servicesFromPlist(mockBundle))
    }
    
    func testURLParser() {
        let mockBundle = Bundle(identifier: "com.wayne.WHCoreServicesTests")!
        let services = Service.servicesFromPlist(mockBundle)
        let path = Service.getPath("mockSearch",
                                   token: ["keyword": "test", "pageSize": "10"],
                                   services: services)
        XCTAssertEqual(path,
                       "http://www.mock.com/v1/search?keyword=test&pageSize=10")
    }

    func testURL() {
        let service = Service(session: session)
        guard let url = URL(string: "http://www.google.com") else {
            XCTAssert(false, "url shouldn't be nil")
            return
        }

        service.get(url: url) { (_, _, _) in
            XCTAssertEqual(self.session.url?.absoluteString, "http://www.google.com")
        }
    }

    func testResumeWasCalled() {
        let service = Service(session: session)
        guard let url = URL(string: "http://www.google.com") else {
            XCTAssert(false, "url shouldn't be nil")
            return
        }

        service.get(url: url) { (_, _, _) in
            XCTAssertEqual(self.session.dataTask.resumeWasCalled, true)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
