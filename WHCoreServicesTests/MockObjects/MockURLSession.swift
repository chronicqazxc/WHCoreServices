import XCTest
@testable import WHCoreServices

class MockURLSession: URLSessionProtocol {

    private (set) var url: URL?
    var dataTask = MockURLSessionDataTask()
// swiftlint:disable all
    func dataTask(with request: URLRequestProtocol,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTaskProtocol {
// swiftlint:enable all
        url = request.url
//        completionHandler(nextData, successHttpURLResponse(request: request), nextError)
        return dataTask
    }
}
