//
//  Error.swift
//  WHCoreServices
//
//  Created by Wayne Hsiao on 2019/4/5.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import Foundation

//public enum GitHubEndpointError: Error {
//    case invalidGitHubEndpoint(endpoint: EndpointFactory)
//    case invalidGitHubEndpointable(endpoint: Endpoint)
//}

public enum APIError: Error {
    case getAccessTokenError
    case getOperationError
    case postOperationError
    case parameterError
    case parseError
    case bearerTokenExpiredError
}
