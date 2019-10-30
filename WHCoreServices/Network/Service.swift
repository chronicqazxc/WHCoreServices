//
//  Service.swift
//  WHCoreServices
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
    public func dataTask(with request: URLRequestProtocol,
                         completionHandler: @escaping NetworkCompletionHandler) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler)
    }

}
extension URLSessionDataTask: URLSessionDataTaskProtocol {
}

extension URLRequest: URLRequestProtocol {

}

@objcMembers
public class Service {

    let session: URLSessionProtocol
    public static var shared = Service()

    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    public func post(url: URL,
                     body: [AnyHashable: Any]? = nil,
                     overrideHeader: [String: String]? = nil,
                     token: String? = nil,
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
            
            if let token = token {
                request = setToken(token: token, to: request)
            }

            resume(request: request,
                   completionHandler: completionHandler)
        } catch {
            print(error.localizedDescription)
            completionHandler(nil, nil, error)
        }
    }

    public func get(url: URL,
                    overrideHeader: [String: String]? = nil,
                    token: String? = nil,
                    completionHandler: @escaping NetworkCompletionHandler) {

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        overrideHeader?.enumerated().forEach({ (arg) in
            request.addValue(arg.element.value, forHTTPHeaderField: arg.element.key)
        })
//        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/vnd.github.machine-man-preview+json", forHTTPHeaderField: "Accept")
        if let token = token {
            request = setToken(token: token, to: request)
        }

        resume(request: request,
               completionHandler: completionHandler)
    }
    
    public func resume(request: URLRequest,
                       completionHandler: @escaping NetworkCompletionHandler) {
        var request = request
        request.cachePolicy = .reloadIgnoringCacheData
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

extension Service {
    static public func servicesFromPlist(_ bundle: Bundle = Bundle.main) -> [String: String]? {

        guard let resourcePath = bundle.path(forResource: "Services", ofType: "plist"),
            let resource = FileManager.default.contents(atPath: resourcePath) else {
                return nil
        }
        do {
            var format = PropertyListSerialization.PropertyListFormat.xml
            guard let services = try PropertyListSerialization.propertyList(from: resource,
                                                                            options: .mutableContainersAndLeaves,
                                                                            format: &format) as? [String: String] else {
                return nil
            }
            return services
        } catch {
            return nil
        }
    }

    static public func getPath(_ key: String,
                               token: [String: String]? = nil,
                               services: [String: String]? = servicesFromPlist()) -> String? {
        
        func valueFromSymbol(_ symbol: String) -> String {
            var value = symbol
            value.removeFirst()
            value.removeLast()
            return value
        }
        
        func symbolFromValue(_ value: String) -> String {
            return "{\(value)}"
        }
        
        guard let services = services,
            let service = services[key],
            let host = service.split(separator: "/").first else {
            return nil
        }
        
        let hostKey = valueFromSymbol(String(host))
        guard let hostValue = services[hostKey] else {
            return nil
        }
        
        var urlPath = service.replacingOccurrences(of: host, with: hostValue)
        if let token = token {
            for keyValue in token {
                urlPath = urlPath.replacingOccurrences(of: symbolFromValue(keyValue.key), with: keyValue.value)
            }
        }

        return urlPath
    }
}

extension Service {
    public func setToken(token: String, to request: URLRequest) -> URLRequest {
        var request = request
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
