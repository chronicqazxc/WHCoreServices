//
//  Service.swift
//  MyService
//
//  Created by Wayne Hsiao on 2019/4/5.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import Foundation

public typealias NetworkCompletionHandler = (Data?, URLResponse?, Error?) -> Swift.Void

public protocol URLRequestProtocol {
    var url: URL? { get set }
}

public protocol URLSessionProtocol {
    func dataTask(with request: URLRequestProtocol,
                  completionHandler: @escaping NetworkCompletionHandler) -> URLSessionDataTaskProtocol
}

public protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSession: URLSessionProtocol {
    public func dataTask(with request: URLRequestProtocol, completionHandler: @escaping NetworkCompletionHandler) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler)
    }

}
extension URLSessionDataTask: URLSessionDataTaskProtocol {
}

extension URLRequest: URLRequestProtocol {

}

public class Service {

    let session: URLSessionProtocol
    public static var shared = Service()

    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    public func post(url: URL,
              body: [AnyHashable: Any]? = nil,
              overrideHeader: [String: String]? = nil,
              completionHandler: @escaping NetworkCompletionHandler) {

        do {
            var request = URLRequest(url: url)

            let jsonData = try JSONSerialization.data(withJSONObject: body as Any, options: .prettyPrinted)
            request.httpBody = jsonData
            request.httpMethod = "POST"
            overrideHeader?.forEach { (key, value) in
                request.addValue(value, forHTTPHeaderField: key)
            }
//            request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
//            request.addValue("application/vnd.github.machine-man-preview+json", forHTTPHeaderField: "Accept")

            if let session = session as? URLSession {
                let task = session.dataTask(with: request) { (data, response, error) in
                    completionHandler(data, response, error)
                }

                task.resume()
            } else {
                let task = session.dataTask(with: request) { (data, response, error) in
                    completionHandler(data, response, error)
                }
                task.resume()
            }
        } catch {
            print(error.localizedDescription)
            completionHandler(nil, nil, error)
        }
    }

    public func get(url: URL,
             overrideHeader: [String: String]? = nil,
             completionHandler: @escaping NetworkCompletionHandler) {

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        overrideHeader?.enumerated().forEach({ (arg) in
            request.addValue(arg.element.value, forHTTPHeaderField: arg.element.key)
        })
//        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/vnd.github.machine-man-preview+json", forHTTPHeaderField: "Accept")

        if let session = session as? URLSession {
            let task = session.dataTask(with: request) { (data, response, error) in
                completionHandler(data, response, error)
            }
            task.resume()
        } else {
            let task = session.dataTask(with: request) { (data, response, error) in
                completionHandler(data, response, error)
            }
            task.resume()
        }
    }
}
